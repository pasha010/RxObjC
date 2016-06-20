//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSchedulerType.h"
#import "RxAnonymousDisposable.h"
#import "RxSchedulerServices+Emulation.h"
#import "RxRecursiveScheduler.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation NSObject (RxSchedulerType)

- (nonnull id <RxDisposable>)schedulePeriodic:(nonnull id)state
                                   startAfter:(RxTimeInterval)startAfter
                                       period:(RxTimeInterval)period
                                       action:(id(^)(id))action {
    RxSchedulePeriodicRecursive *schedule = [[RxSchedulePeriodicRecursive alloc] initWithScheduler:self
                                                                                        startAfter:startAfter
                                                                                            period:period
                                                                                            action:action
                                                                                             state:state];
    return [schedule start];
}

- (nonnull id <RxDisposable>)scheduleRecursive:(nonnull id)state 
                                       dueTime:(RxTimeInterval)dueTime 
                                        action:(RxAnyRecursiveSchedulerAction)action {
    RxAnyRecursiveScheduler *scheduler = [[RxAnyRecursiveScheduler alloc] initWithScheduler:self andAction:action];
    [scheduler schedule:state dueTime:dueTime];
    return [[RxAnonymousDisposable alloc] initWithDisposeAction:^{
        [scheduler dispose];
    }];
}

@end
#pragma clang diagnostic pop