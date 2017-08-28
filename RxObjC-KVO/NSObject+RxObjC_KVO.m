//
//  NSObject+RxObjC_KVO.m
//  RxObjC-KVO
//
//  Created by Pavel Malkov on 11.07.17.
//  Copyright © 2017 Pavel Malkov. All rights reserved.
//

#import "NSObject+RxObjC_KVO.h"
#import <RxObjC/RxObjC.h>
#import <RxObjC_Dealloc/RxObjC_Dealloc.h>

@protocol RxKVOObservableProtocol <NSObject>

- (nullable id)target;
- (nonnull NSString *)keyPath;
- (BOOL)retainTarget;
- (NSKeyValueObservingOptions)options;

@end

typedef void (^RxKVOCallback)(id _Nullable object);

@interface RxKVOObserver : NSObject <RxDisposable>

@property (nullable, weak, nonatomic) RxKVOObserver *retainSelf;

@property (nonatomic, unsafe_unretained) id target;
@property (nullable, nonatomic, strong) id retainedTarget;
@property (nonnull, nonatomic, copy) NSString *keyPath;
@property (nonnull, nonatomic, copy) RxKVOCallback callback;

- (nonnull instancetype)initWithParent:(nonnull id <RxKVOObservableProtocol>)parent callback:(nonnull RxKVOCallback)callback;

@end

@interface RxKVOObservable<Element> : NSObject <RxObservableType, RxKVOObservableProtocol>

@property (nullable, weak, nonatomic) id target;
@property (nonnull, strong, nonatomic) NSString *keyPath;
@property (assign, nonatomic) BOOL retainTarget;
@property (assign, nonatomic) NSKeyValueObservingOptions options;

@property (nonnull, strong, nonatomic) id strongTarget;

- (nonnull instancetype)initWithObject:(nonnull id)target
                               keyPath:(nonnull NSString *)keyPath
                               options:(NSKeyValueObservingOptions)options
                          retainTarget:(BOOL)retainTarget;

@end

#if !DISABLE_SWIZZLING

FOUNDATION_EXTERN NSInteger const RxObjCInvalidPropertyNameError;

@interface RxObservable<E> (FinishWhenDealloc)

- (nonnull RxObservable<E> *)finishWithNilWhenDealloc:(nonnull NSObject *)target;

@end

FOUNDATION_EXTERN RxObservable *__nonnull rx_observeWeaklyKeyPathSectionsFor(NSObject *_Nonnull target,
        NSArray<NSString *> *_Nonnull keyPathSections,
        NSKeyValueObservingOptions options);

#endif

@implementation NSObject (RxKVOObserving)

- (nonnull RxObservable *)rx_observe:(nonnull NSString *)keyPath options:(NSKeyValueObservingOptions)options retainSelf:(BOOL)retainSelf {
    return [[[RxKVOObservable alloc] initWithObject:self keyPath:keyPath options:options retainTarget:retainSelf] asObservable];
}

- (nonnull RxObservable *)rx_observe:(nonnull NSString *)keyPath options:(NSKeyValueObservingOptions)options {
    return [self rx_observe:keyPath options:options retainSelf:YES];
}

- (nonnull RxObservable *)rx_observe:(nonnull NSString *)keyPath {
    return [self rx_observe:keyPath options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew];
}

@end

#if !DISABLE_SWIZZLING

@implementation NSObject (RxKVOWeakly)

- (nonnull RxObservable *)rx_observeWeakly:(nonnull NSString *)keyPath options:(NSKeyValueObservingOptions)options {
    NSArray<NSString *> *components = [[keyPath componentsSeparatedByString:@"."] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, NSDictionary<NSString *, id> *bindings) {
        return ![evaluatedObject isEqualToString:@"self"];
    }]];


    RxObservable *observable = [rx_observeWeaklyKeyPathSectionsFor(self, components, options) finishWithNilWhenDealloc:self];

    if ((options & NSKeyValueObservingOptionInitial) != 0) {
        return observable;
    } else {
        return [observable skip:1];
    }
}

- (nonnull RxObservable *)rx_observeWeakly:(nonnull NSString *)keyPath {
    return [self rx_observeWeakly:keyPath options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew];
}

@end

#endif

@implementation RxKVOObservable

- (nonnull instancetype)initWithObject:(nonnull id)target
                               keyPath:(nonnull NSString *)keyPath
                               options:(NSKeyValueObservingOptions)options
                          retainTarget:(BOOL)retainTarget{
    self = [super init];
    if (self) {
        _target = target;
        _keyPath = keyPath;
        _options = options;
        _retainTarget = retainTarget;
        if (retainTarget) {
            _strongTarget = target;
        }
    }

    return self;
}

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    RxKVOObserver *kvoObserver = [[RxKVOObserver alloc] initWithParent:self callback:^(id object) {
        if ([object isKindOfClass:[NSNull class]]) {
            [observer on:[RxEvent next:nil]];
        } else {
            [observer on:[RxEvent next:object]];
        }
    }];

    return [RxAnonymousDisposable create:^{
        [kvoObserver dispose];
    }];
}

- (nonnull RxObservable *)asObservable {
    return [RxObservable create:^id <RxDisposable>(RxAnyObserver *observer) {
        return [self subscribe:observer];
    }];
}

@end

#if !DISABLE_SWIZZLING

static BOOL rx_isWeakProperty(NSString *__nonnull propertyRuntimeInfo) {
    return [propertyRuntimeInfo rangeOfString:@",W,"].location != NSNotFound;
}

NSInteger const RxObjCInvalidPropertyNameError = 124;

@implementation RxObservable (FinishWhenDealloc)

- (nonnull RxObservable *)finishWithNilWhenDealloc:(nonnull NSObject *)target {
    return [[[target.rx_deallocating
            map:^id(id __unused _) {
                return [RxObservable just:nil];
            }]
            startWith:[self asObservable]]
            switchLatest];
}

@end

FOUNDATION_EXTERN RxObservable *__nonnull rx_observeWeaklyKeyPathSectionsFor(NSObject *__nonnull target, NSArray<NSString *> *__nonnull keyPathSections, NSKeyValueObservingOptions options) {
    NSString *propertyName = keyPathSections.firstObject;
    NSArray<NSString *> *remainingPaths = keyPathSections.count > 1 ? [keyPathSections subarrayWithRange:NSMakeRange(1, keyPathSections.count - 1)] : nil;

    objc_property_t pProperty = class_getProperty(object_getClass(target), propertyName.UTF8String);

    if (pProperty == nil) {
        NSError *error = [NSError errorWithDomain:@"rx.objc"
                                             code:RxObjCInvalidPropertyNameError
                                         userInfo:@{NSLocalizedDescriptionKey: @"invalid property name"}];
        return [RxObservable error:error];
    }

    char const *propertyAttributes = property_getAttributes(pProperty);

    // should dealloc hook be in place if week property, or just create strong reference because it doesn't matter
    BOOL isWeak = rx_isWeakProperty([NSString stringWithUTF8String:propertyAttributes]);

    RxKVOObservable *propertyObservable = [[RxKVOObservable alloc] initWithObject:target keyPath:propertyName options:options | NSKeyValueObservingOptionInitial retainTarget:NO];

    @weakify(target);
    return [propertyObservable.asObservable flatMapLatest:^id <RxObservableConvertibleType>(id nextTarget) {
        if (!nextTarget) {
            return [RxObservable just:nil];
        }

        NSObject *nextObject = nextTarget;
        @strongify(target);

        // if target is alive, then send change
        // if it's deallocated, don't send anything
        if (!target) {
            return [RxObservable empty];
        }

        RxObservable *nextElementsObservable = keyPathSections.count == 1 ? [RxObservable just:nextTarget] : rx_observeWeaklyKeyPathSectionsFor(nextObject, remainingPaths, options);

        if (isWeak) {
            return [nextElementsObservable finishWithNilWhenDealloc:nextObject];
        }
        return nextElementsObservable;
    }];
}

#endif

@implementation RxKVOObserver

- (nonnull instancetype)initWithParent:(nonnull id <RxKVOObservableProtocol>)parent callback:(nonnull RxKVOCallback)callback {
    self = [super init];
    if (self) {
#if TRACE_RESOURCES
        OSAtomicIncrement32(&rx_resourceCount);
#endif
        _target = parent.target;
        if (parent.retainTarget) {
            _retainedTarget = parent.target;
        }
        _keyPath = parent.keyPath;
        _callback = callback;

        [_target addObserver:self forKeyPath:_keyPath options:parent.options context:nil];
        _retainSelf = self;
    }
    return self;
}

- (void)dispose {
    [_target removeObserver:self forKeyPath:_keyPath context:nil];
    _target = nil;
    _retainedTarget = nil;
    _retainSelf = nil;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSString *, id> *)change
                       context:(nullable void *)context {
    @synchronized (self) {
        self->_callback(change[NSKeyValueChangeNewKey]);
    }
}

#if TRACE_RESOURCES
- (void)dealloc {
    OSAtomicDecrement32(&rx_resourceCount);
}
#endif

@end