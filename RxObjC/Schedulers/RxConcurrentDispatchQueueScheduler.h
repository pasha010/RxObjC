//
//  RxConcurrentDispatchQueueScheduler
//  RxObjC
// 
//  Created by Pavel Malkov on 14.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxSchedulerType.h"

@class RxDispatchQueueSchedulerQOS;

NS_ASSUME_NONNULL_BEGIN

/**
Abstracts the work that needs to be performed on a specific `dispatch_queue_t`. You can also pass a serial dispatch queue, it shouldn't cause any problems.

This scheduler is suitable when some work needs to be performed in background.
*/
@interface RxConcurrentDispatchQueueScheduler : NSObject <RxSchedulerType>

@property (nonnull, readonly) NSDate *now;

/**
Constructs new `ConcurrentDispatchQueueScheduler` that wraps `queue`.

- parameter queue: Target dispatch queue.
*/
- (nonnull instancetype)initWithQueue:(dispatch_queue_t)queue;

- (nonnull instancetype)initWithGlobalConcurrentQueueQOS:(nonnull RxDispatchQueueSchedulerQOS *)globalConcurrentQueueQOS NS_AVAILABLE(10_10, 8_0);

+ (uint64_t)convertTimeIntervalToDispatchInterval:(NSTimeInterval)timeInterval;

+ (dispatch_time_t)convertTimeIntervalToDispatchTime:(NSTimeInterval)timeInterval;

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
- (nonnull id <RxDisposable>)scheduleRelative:(nullable id)state dueTime:(RxTimeInterval)dueTime action:(id <RxDisposable>(^)(id))action;

/**
Schedules a periodic piece of work.

- parameter state: State passed to the action to be executed.
- parameter startAfter: Period after which initial work should be run.
- parameter period: Period for running the work periodically.
- parameter action: Action to be executed.
- returns: The disposable object used to cancel the scheduled action (best effort).
*/
- (nonnull id <RxDisposable>)schedulePeriodic:(nullable id)state
                                   startAfter:(RxTimeInterval)startAfter
                                       period:(RxTimeInterval)period
                                       action:(id(^)(id __nullable ))action;

@end

NS_ASSUME_NONNULL_END