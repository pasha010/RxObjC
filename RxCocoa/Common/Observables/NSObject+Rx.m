//
//  NSObject(Rx)
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "NSObject+Rx.h"
#import "RxDeallocObservable.h"
#import <objc/runtime.h>

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

@end