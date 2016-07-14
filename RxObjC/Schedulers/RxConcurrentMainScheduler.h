//
//  RxConcurrentMainScheduler
//  RxObjC
// 
//  Created by Pavel Malkov on 14.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxSchedulerType.h"

NS_ASSUME_NONNULL_BEGIN

/**
Abstracts work that needs to be performed on `MainThread`. In case `schedule` methods are called from main thread, it will perform action immediately without scheduling.

This scheduler is optimized for `subscribeOn` operator. If you want to observe observable sequence elements on main thread using `observeOn` operator,
`MainScheduler` is more suitable for that purpose.
*/
@interface RxConcurrentMainScheduler : NSObject <RxSchedulerType>

@property (nonnull, readonly) NSDate *now;

+ (nonnull instancetype)instance;

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