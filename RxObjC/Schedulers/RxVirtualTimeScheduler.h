//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxSchedulerType.h"
#import "RxVirtualTimeConverterType.h"

@protocol RxVirtualTimeConverterType;

NS_ASSUME_NONNULL_BEGIN

@interface RxVirtualTimeScheduler<__covariant Converter : id <RxVirtualTimeConverterType>> : NSObject <RxSchedulerType>

/**
- returns: Scheduler's absolute time clock value.
*/
@property (nonnull, strong, readonly) RxVirtualTimeUnit clock;

/**
 Creates a new virtual time scheduler.

 - parameter initialClock: Initial value for the clock.
*/
- (nonnull instancetype)initWithInitialClock:(nonnull RxVirtualTimeUnit)initialClock
                                andConverter:(nonnull id <RxVirtualTimeConverterType>)converter;

/**
Schedules an action to be executed immediatelly.

- parameter state: State passed to the action to be executed.
- parameter action: Action to be executed.
- returns: The disposable object used to cancel the scheduled action (best effort).
*/
- (nonnull id <RxDisposable>)schedule:(nullable RxStateType)state action:(nonnull id <RxDisposable> (^)(RxStateType __nullable))action;

/**
 Schedules an action to be executed.

 - parameter state: State passed to the action to be executed.
 - parameter dueTime: Relative time after which to execute the action.
 - parameter action: Action to be executed.
 - returns: The disposable object used to cancel the scheduled action (best effort).
 */
- (nonnull id <RxDisposable>)scheduleRelative:(nullable id)state
                                      dueTime:(RxTimeInterval)dueTime
                                       action:(id <RxDisposable>(^)(id))action;

/**
 Schedules an action to be executed after relative time has passed.

 - parameter state: State passed to the action to be executed.
 - parameter time: Absolute time when to execute the action. If this is less or equal then `now`, `now + 1`  will be used.
 - parameter action: Action to be executed.
 - returns: The disposable object used to cancel the scheduled action (best effort).
 */
- (nonnull id <RxDisposable>)scheduleRelativeVirtual:(nullable id)state
                                             dueTime:(RxVirtualTimeIntervalUnit)dueTime
                                              action:(id <RxDisposable>(^)(id __nullable))action;

/**
 Schedules an action to be executed at absolute virtual time.

 - parameter state: State passed to the action to be executed.
 - parameter time: Absolute time when to execute the action.
 - parameter action: Action to be executed.
 - returns: The disposable object used to cancel the scheduled action (best effort).
 */
- (nonnull id <RxDisposable>)scheduleAbsoluteVirtual:(nullable id)state
                                                time:(nonnull RxVirtualTimeUnit)time
                                              action:(id <RxDisposable>(^)(id __nullable))action;

/**
Adjusts time of scheduling before adding item to schedule queue.
*/
- (nonnull RxVirtualTimeUnit)adjustScheduledTime:(nonnull RxVirtualTimeUnit)time;

/**
Starts the virtual time scheduler.
*/
- (void)start;

/**
 Advances the scheduler's clock to the specified time, running all work till that point.

 - parameter virtualTime: Absolute time to advance the scheduler's clock to.
*/
- (void)advanceTo:(nonnull RxVirtualTimeUnit)virtualTime;

/**
Advances the scheduler's clock by the specified relative time.
*/
- (void)sleep:(RxVirtualTimeIntervalUnit)virtualInterval;

/**
Stops the virtual time scheduler.
*/
- (void)stop;

@end

NS_ASSUME_NONNULL_END