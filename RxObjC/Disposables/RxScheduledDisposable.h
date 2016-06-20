//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxCancelable.h"
#import "RxImmediateSchedulerType.h"

NS_ASSUME_NONNULL_BEGIN

/**
Represents a disposable resource whose disposal invocation will be scheduled on the specified scheduler.
*/
@interface RxScheduledDisposable : NSObject <RxCancelable>

@property (nonnull, strong, nonatomic) id <RxImmediateSchedulerType> scheduler;

/**
Initializes a new instance of the `ScheduledDisposable` that uses a `scheduler` on which to dispose the `disposable`.

- parameter scheduler: Scheduler where the disposable resource will be disposed on.
- parameter disposable: Disposable resource to dispose on the given scheduler.
*/
- (nonnull instancetype)initWithScheduler:(nonnull id <RxImmediateSchedulerType>)scheduler
                            andDisposable:(nonnull id <RxDisposable>)disposable;

@end

NS_ASSUME_NONNULL_END