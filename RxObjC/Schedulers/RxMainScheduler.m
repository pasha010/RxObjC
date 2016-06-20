//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxMainScheduler.h"
#import "RxObjC.h"

@implementation RxMainScheduler

+ (void)ensureExecutingOnScheduler {
    if (![NSThread currentThread].isMainThread) {
        rx_fatalError(@"Executing on backgound thread. Please use `MainScheduler.instance.schedule` to schedule work on main thread.");
    }
}

@end