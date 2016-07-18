//
//  _RxDelegateProxy.m
//  RxCocoa
//
//  Created by Pavel Malkov on 18.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import "_RxDelegateProxy.h"
#import "_Rx.h"
#import "_RxObjCRuntime.h"

@interface _RxDelegateProxy ()

@property (nonatomic, strong) id strongForwardDelegate;

@end

static NSMutableDictionary *forwardableSelectorsPerClass = nil;

@implementation _RxDelegateProxy

+ (nonnull NSSet<NSValue *> *)collectSelectorsForProtocol:(nonnull Protocol *)protocol {
    NSMutableSet *selectors = [NSMutableSet set];

    unsigned int protocolMethodCount = 0;
    struct objc_method_description *pMethods = protocol_copyMethodDescriptionList(protocol, NO, YES, &protocolMethodCount);

    for (unsigned int i = 0; i < protocolMethodCount; ++i) {
        struct objc_method_description method = pMethods[i];
        if (Rx_is_method_with_description_void(method)) {
            [selectors addObject:SEL_VALUE(method.name)];
        }
    }

    free(pMethods);

    unsigned int numberOfBaseProtocols = 0;
    Protocol *__unsafe_unretained *pSubprotocols = protocol_copyProtocolList(protocol, &numberOfBaseProtocols);

    for (unsigned int i = 0; i < numberOfBaseProtocols; ++i) {
        [selectors unionSet:[self collectSelectorsForProtocol:pSubprotocols[i]]];
    }

    free(pSubprotocols);

    return selectors;
}

+ (void)initialize {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if (forwardableSelectorsPerClass == nil) {
            forwardableSelectorsPerClass = [[NSMutableDictionary alloc] init];
        }

        NSMutableSet *allowedSelectors = [NSMutableSet set];

#define CLASS_HIERARCHY_MAX_DEPTH 100

        NSInteger classHierarchyDepth = 0;
        Class targetClass = self;

        for (classHierarchyDepth = 0, targetClass = self;
             classHierarchyDepth < CLASS_HIERARCHY_MAX_DEPTH && targetClass != nil;
             ++classHierarchyDepth, targetClass = class_getSuperclass(targetClass)
                ) {
            unsigned int count;
            Protocol *__unsafe_unretained *pProtocols = class_copyProtocolList(targetClass, &count);

            for (unsigned int i = 0; i < count; i++) {
                NSSet *selectorsForProtocol = [self collectSelectorsForProtocol:pProtocols[i]];
                [allowedSelectors unionSet:selectorsForProtocol];
            }

            free(pProtocols);
        }

        if (classHierarchyDepth == CLASS_HIERARCHY_MAX_DEPTH) {
            NSLog(@"Detected weird class hierarchy with depth over %d. Starting with this class -> %@", CLASS_HIERARCHY_MAX_DEPTH, self);
#if DEBUG
            abort();
#endif
        }

        forwardableSelectorsPerClass[CLASS_VALUE(self)] = allowedSelectors;
    });
}

- (void)interceptedSelector:(SEL)selector withArguments:(NSArray *)arguments {

}

- (void)_setForwardToDelegate:(id)forwardToDelegate retainDelegate:(BOOL)retainDelegate {
    __forwardToDelegate = forwardToDelegate;
    if (retainDelegate) {
        self.strongForwardDelegate = forwardToDelegate;
    }
    else {
        self.strongForwardDelegate = nil;
    }
}

- (BOOL)hasWiredImplementationForSelector:(SEL)selector {
    return [super respondsToSelector:selector];
}

- (BOOL)canRespondToSelector:(SEL)selector {
    @synchronized (_RxDelegateProxy.class) {
        NSSet *allowedMethods = forwardableSelectorsPerClass[CLASS_VALUE(self.class)];
        NSAssert(allowedMethods != nil, @"Set of allowed methods not initialized");
        return [allowedMethods containsObject:SEL_VALUE(selector)];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector]
            || [self._forwardToDelegate respondsToSelector:aSelector]
            || [self canRespondToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if (Rx_is_method_signature_void(anInvocation.methodSignature)) {
        NSArray *arguments = Rx_extract_arguments(anInvocation);
        [self interceptedSelector:anInvocation.selector withArguments:arguments];
    }

    if (self._forwardToDelegate && [self._forwardToDelegate respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:self._forwardToDelegate];
    }
}

- (void)dealloc {
}


@end
