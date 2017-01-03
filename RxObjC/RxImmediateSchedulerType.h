//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxSchedulersTypes.h"

@protocol RxDisposable;

NS_ASSUME_NONNULL_BEGIN

typedef id RxStateType;

/**
 * Represents an object that immediately schedules units of work.
 */
@protocol RxImmediateSchedulerType <NSObject>
@optional
/**
 * Schedules an action to be executed immediatelly.
 * @param state - State passed to the action to be executed.
 * @param action -  Action to be executed.
 * @return - The disposable object used to cancel the scheduled action (best effort).
*/
- (nonnull id <RxDisposable>)schedule:(nullable RxStateType)state action:(nonnull id <RxDisposable> (^)(RxStateType __nullable))action;

@end

@interface RxImmediateScheduler : NSObject <RxImmediateSchedulerType>

/**
 * Schedules an action to be executed recursively.
 *
 * @param state - State passed to the action to be executed.
 * @param action - Action to execute recursively. The last parameter passed to the action is used to trigger recursive scheduling of the action, passing in recursive invocation state.
 * @return - The disposable object used to cancel the scheduled action (best effort).
*/
- (nonnull id <RxDisposable>)scheduleRecursive:(nullable RxStateType)state action:(RxRecursiveImmediateAction)action;

@end

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

@optional
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

@required
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

- (nonnull id <RxDisposable>)scheduleRecursive:(nonnull id)state
                                       dueTime:(RxTimeInterval)dueTime
                                        action:(RxAnyRecursiveSchedulerAction)action;

@end

@interface RxScheduler : RxImmediateScheduler <RxSchedulerType>
@end


NS_ASSUME_NONNULL_END