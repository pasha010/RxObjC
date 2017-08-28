//
//  NSObject+RxObjC_Dealloc.h
//  NSObject+RxObjC_Dealloc
//
//  Created by Pavel Malkov on 25.08.17.
//  Copyright © 2017 Pavel Malkov. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+RxObjC_Dealloc.h"
#import "RxDeallocObservable.h"
#import <RxObjC/RxReplaySubject.h>

@implementation NSObject (RxObjC_Dealloc)

- (nonnull RxObservable<id> *)rx_deallocated {
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

@end