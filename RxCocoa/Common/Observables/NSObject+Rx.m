//
//  NSObject(Rx)
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "NSObject+Rx.h"
#import "RxDeallocObservable.h"
#import "RxDeallocatingObservable.h"
#import "RxCocoaCommon.h"
#import "RxKVOObservable.h"
#import <objc/runtime.h>

SEL rx_deallocSelector() {
    static SEL rx_deallocSelector;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        rx_deallocSelector = NSSelectorFromString(@"dealloc");
    });
    return rx_deallocSelector;
}

SEL rxDeallocatingSelector() {
    static SEL rxDeallocatingSelector;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        rxDeallocatingSelector = Rx_selector(rx_deallocSelector());
    });
    return rxDeallocatingSelector;
}

SEL rxDeallocatingSelectorReference() {
    static SEL rxDeallocatingSelectorReference;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        rxDeallocatingSelectorReference = Rx_reference_from_selector(rxDeallocatingSelector());
    });
    return rxDeallocatingSelectorReference;
}


@implementation NSObject (RxKVOObserving)

- (nonnull RxObservable *)rx_observe:(nonnull NSString *)keyPath options:(NSKeyValueObservingOptions)options retainSelf:(BOOL)retainSelf {
    return [[[RxKVOObservable alloc] initWithObject:self keyPath:keyPath options:options retainTarget:retainSelf] asObservable];
}

- (RxObservable *)rx_observe:(nonnull NSString *)keyPath options:(NSKeyValueObservingOptions)options {
    return [self rx_observe:keyPath options:options retainSelf:YES];
}


@end

@implementation NSObject (RxDealloc)

- (nonnull RxObservable *)rx_deallocated {
    @synchronized (self) {
        RxDeallocObservable *deallocObservable = objc_getAssociatedObject(self, @selector(rx_deallocated));
        if (deallocObservable) {
            return deallocObservable.subject;
        }

        deallocObservable = [[RxDeallocObservable alloc] init];

        objc_setAssociatedObject(self, @selector(rx_deallocated), deallocObservable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        return deallocObservable.subject;
    }
}

#if !DISABLE_SWIZZLING

- (nonnull RxObservable *)rx_deallocating {
    @synchronized (self) {
        RxDeallocatingObservable *subject;
        RxDeallocatingObservable *existingSubject = objc_getAssociatedObject(self, rxDeallocatingSelectorReference());
        if (existingSubject) {
            subject = existingSubject;
        } else {
            subject = [[RxDeallocatingObservable alloc] init];
            objc_setAssociatedObject(self, rxDeallocatingSelectorReference(), subject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }

        if (subject.isActive) {
            return [subject asObservable];
        }

        NSError *error = nil;
        IMP targetImplementation = Rx_ensure_observing(self, rx_deallocSelector(), &error);

        if (!targetImplementation) {
            return [RxObservable error:error ? [error rxCocoaErrorForTarget:self] : [RxCocoaError unknown]];
        }

        subject.targetImplementation = targetImplementation;

        return [subject asObservable];
    }
}

#endif

@end