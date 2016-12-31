//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxImmediateSchedulerType.h"

typedef NS_ENUM(NSUInteger, RxSchedulePeriodicRecursiveCommand) {
    RxSchedulePeriodicRecursiveCommandTick,
    RxSchedulePeriodicRecursiveCommandDispatchStart
};

NS_ASSUME_NONNULL_BEGIN

typedef __nonnull id (^RxRecursiveAction)(__nonnull id);

@interface RxSchedulePeriodicRecursive<State> : NSObject

- (nonnull instancetype)initWithScheduler:(nonnull id <RxSchedulerType>)scheduler
                               startAfter:(RxTimeInterval)startAfter
                                   period:(RxTimeInterval)period
                                   action:(RxRecursiveAction)action
                                    state:(nonnull State)state;

- (nonnull id <RxDisposable>)start;

@end

NS_ASSUME_NONNULL_END