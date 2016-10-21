//
//  RxObservable(Concurrency)
//  RxObjC
// 
//  Created by Pavel Malkov on 26.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable+Concurrency.h"
#import "RxImmediateSchedulerType.h"
#import "RxSerialDispatchQueueScheduler.h"
#import "RxObserveOnSerialDispatchQueue.h"
#import "RxObserveOn.h"
#import "RxSubscribeOn.h"
#import "RxMainScheduler.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma GCC diagnostic ignored "-Wprotocol"

@implementation NSObject (RxObserveOn)

- (nonnull RxObservable *)observeOn:(nonnull id <RxImmediateSchedulerType>)scheduler {
    if ([scheduler isKindOfClass:[RxSerialDispatchQueueScheduler class]]) {
        RxSerialDispatchQueueScheduler *queueScheduler = (RxSerialDispatchQueueScheduler *) scheduler;
        return [[RxObserveOnSerialDispatchQueue alloc] initWithSource:[self asObservable] scheduler:queueScheduler];
    }
    return [[RxObserveOn alloc] initWithSource:[self asObservable] scheduler:scheduler];
}

- (nonnull RxObservable *)observeOnMainThread {
    return [self observeOn:[RxMainScheduler instance]];
}

@end

@implementation NSObject (RxSubscribeOn)

- (nonnull RxObservable *)subscribeOn:(nonnull id <RxImmediateSchedulerType>)scheduler {
    return [[RxSubscribeOn alloc] initWithSource:self scheduler:scheduler];
}

@end

#pragma clang diagnostic pop