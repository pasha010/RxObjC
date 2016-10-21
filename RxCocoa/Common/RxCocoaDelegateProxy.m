//
//  RxCocoaDelegateProxy
//  RxObjC
// 
//  Created by Pavel Malkov on 05.09.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxCocoaDelegateProxy.h"

uint8_t rx_delegateAssociatedTag = 0;
uint8_t rx_dataSourceAssociatedTag = 0;

@interface RxCocoaDelegateProxy ()
/**
 * Parent object associated with delegate proxy.
 */
@property (nullable, nonatomic, weak) id parentObject;

@property (nonnull, nonatomic, strong) NSMutableDictionary<NSString *, RxPublishSubject *> *subjectsForSelector;

@end

@implementation RxCocoaDelegateProxy

- (nonnull instancetype)initWithParentObject:(nonnull id)parentObject {
    self = [super init];
    if (self) {
        self.parentObject = parentObject;
        self.subjectsForSelector = [NSMutableDictionary dictionary];
        [RxMainScheduler ensureExecutingOnScheduler];
#if TRACE_RESOURCES
        OSAtomicIncrement32(&rx_resourceCount);
#endif
    }
    return self;
}

- (nonnull RxObservable<NSArray *> *)observe:(nonnull SEL)selector {
    NSString *selectorKey = NSStringFromSelector(selector);
    if ([self hasWiredImplementationForSelector:selector]) {
        NSLog(@"Delegate proxy is already implementing (%@), a more performant way of registering might exist.", selectorKey);
    }
    
    if (![self respondsToSelector:selector]) {
        rx_fatalError([NSString stringWithFormat:@"This class doesn't respond to selector (%@)", selectorKey]);
    }

    RxPublishSubject *subject = self.subjectsForSelector[selectorKey];

    if (!subject) {
        subject = [RxPublishSubject create];
        self.subjectsForSelector[selectorKey] = subject;
    }
    return subject;
}

#pragma mark - proxy

- (void)interceptedSelector:(SEL)selector withArguments:(NSArray *)arguments {
    [self.subjectsForSelector[NSStringFromSelector(selector)] on:[RxEvent next:arguments]];
}

+ (const void *)delegateAssociatedObjectTag {
    return [RxCocoaDelegateProxy _pointer:&rx_delegateAssociatedTag];
}

+ (nonnull instancetype)createProxyForObject:(nonnull id)object {
    return [[RxCocoaDelegateProxy alloc] initWithParentObject:object];
}

+ (nullable id)assignedProxyFor:(nonnull id)object {
    id maybeDelegate = objc_getAssociatedObject(object, [self delegateAssociatedObjectTag]);
    return maybeDelegate;
}

+ (void)assignProxy:(nonnull id)proxy toObject:(nonnull id)object {
    if (![proxy isKindOfClass:[self classForCoder]]) {
        NSLog(@"precondition(proxy.isKindOfClass(self.classForCoder()))");
    }
    objc_setAssociatedObject(object, [self delegateAssociatedObjectTag], proxy, OBJC_ASSOCIATION_RETAIN);
}

- (void)setForwardToDelegate:(nullable id)delegate retainDelegate:(BOOL)retainDelegate {
    [self _setForwardToDelegate:delegate retainDelegate:retainDelegate];
}

- (nullable id)forwardToDelegate {
    return [self _forwardToDelegate];
}

- (void)dealloc {
    for (RxPublishSubject *v in self.subjectsForSelector.allValues) {
        [v onCompleted];
    }
#if TRACE_RESOURCES
    OSAtomicDecrement32(&rx_resourceCount);
#endif
}

#pragma mark - pointer
+ (const void *)_pointer:(const void *)p {
    return p;
}

@end