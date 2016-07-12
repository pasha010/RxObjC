//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxSchedulers.h"

@protocol RxDisposable;

NS_ASSUME_NONNULL_BEGIN

typedef id RxStateType;

/**
Represents an object that immediately schedules units of work.
*/
@protocol RxImmediateSchedulerType <NSObject>
/**
Schedules an action to be executed immediatelly.

- parameter state: State passed to the action to be executed.
- parameter action: Action to be executed.
- returns: The disposable object used to cancel the scheduled action (best effort).
*/
- (nonnull id <RxDisposable>)schedule:(nullable RxStateType)state action:(nonnull id <RxDisposable> (^)(RxStateType __nullable))action;

@end

@interface NSObject (RxImmediateSchedulerType) <RxImmediateSchedulerType>

/**
Schedules an action to be executed recursively.

- parameter state: State passed to the action to be executed.
- parameter action: Action to execute recursively. The last parameter passed to the action is used to trigger recursive scheduling of the action, passing in recursive invocation state.
- returns: The disposable object used to cancel the scheduled action (best effort).
*/
- (nonnull id <RxDisposable>)scheduleRecursive:(nullable RxStateType)state action:(RxRecursiveImmediateAction)action;

@end

NS_ASSUME_NONNULL_END