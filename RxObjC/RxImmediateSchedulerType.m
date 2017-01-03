//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxImmediateSchedulerType.h"
#import "RxAnonymousDisposable.h"
#import "RxRecursiveScheduler.h"
#import "RxSchedulerServices+Emulation.h"

@implementation RxImmediateScheduler

- (nonnull id <RxDisposable>)scheduleRecursive:(nullable id)state action:(RxRecursiveImmediateAction)action {
    RxRecursiveImmediateScheduler *recursiveScheduler = [[RxRecursiveImmediateScheduler alloc] initWithActon:action andScheduler:self];

    [recursiveScheduler schedule:state];

    return [[RxAnonymousDisposable alloc] initWithDisposeAction:^{[recursiveScheduler dispose];}];
}

@end

@implementation RxScheduler

- (nonnull id <RxDisposable>)schedulePeriodic:(nullable id)state
                                   startAfter:(RxTimeInterval)startAfter
                                       period:(RxTimeInterval)period
                                       action:(id(^)(id __nullable))action {
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