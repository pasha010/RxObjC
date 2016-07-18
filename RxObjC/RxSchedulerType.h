//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxImmediateSchedulerType.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Type that represents time interval in the context of RxSwift.
 */
typedef NSTimeInterval RxTimeInterval;

/**
 * Type that represents absolute time in the context of RxSwift.
 */
typedef NSDate RxTime;

/**
 * Represents an object that schedules units of work.
 */
@protocol RxSchedulerType <RxImmediateSchedulerType>

/**
 * @return: Current time.
*/
- (nonnull RxTime *)now;

/**
 * Schedules an action to be executed.
 * @param state: State passed to the action to be executed.
 * @param dueTime: Relative time after which to execute the action.
 * @param action: Action to be executed.
 * @return: The disposable object used to cancel the scheduled action (best effort).
 */
- (nonnull id <RxDisposable>)scheduleRelative:(nullable id)state
                                      dueTime:(RxTimeInterval)dueTime
                                       action:(id <RxDisposable>(^)(id))action;

/**
 * Schedules a periodic piece of work.
 * @param state: State passed to the action to be executed.
 * @param startAfter: Period after which initial work should be run.
 * @param period: Period for running the work periodically.
 * @param action: Action to be executed.
 * @return: The disposable object used to cancel the scheduled action (best effort).
 */
- (nonnull id <RxDisposable>)schedulePeriodic:(nullable id)state
                                   startAfter:(RxTimeInterval)startAfter
                                       period:(RxTimeInterval)period
                                       action:(nonnull id(^)(id __nullable))action;

@end

@interface NSObject (RxSchedulerType) <RxSchedulerType>

/**
 * Periodic task will be emulated using recursive scheduling.
 * @param state: Initial state passed to the action upon the first iteration.
 * @param startAfter: Period after which initial work should be run.
 * @param period: Period for running the work periodically.
 * @return: The disposable object used to cancel the scheduled recurring action (best effort).
 */
- (nonnull id <RxDisposable>)schedulePeriodic:(nullable id)state
                                   startAfter:(RxTimeInterval)startAfter
                                       period:(RxTimeInterval)period
                                       action:(id(^)(id __nullable ))action;

- (nonnull id <RxDisposable>)scheduleRecursive:(nonnull id)state
                                       dueTime:(RxTimeInterval)dueTime
                                        action:(RxAnyRecursiveSchedulerAction)action;

@end

NS_ASSUME_NONNULL_END