//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxImmediateSchedulerType.h"

@protocol RxImmediateSchedulerType;

NS_ASSUME_NONNULL_BEGIN
@class RxAnyRecursiveScheduler;
@protocol RxSchedulerType;

/**
 * Type erased recursive scheduler.
 */
@interface RxAnyRecursiveScheduler<__covariant State> : NSObject

- (nonnull instancetype)initWithScheduler:(nonnull id <RxSchedulerType>)scheduler andAction:(RxAnyRecursiveSchedulerAction)action;

/**
 * Schedules an action to be executed recursively.
 * @param state: State passed to the action to be executed.
 * @param dueTime: Relative time after which to execute the recursive action.
 */
- (void)schedule:(nonnull State)state dueTime:(RxTimeInterval)dueTime;

/**
 * Schedules an action to be executed recursively.
 * @param state: State passed to the action to be executed.
 */
- (void)schedule:(nonnull State)state;

- (void)dispose;

@end

/**
 * Type erased recursive scheduler.
 */
@interface RxRecursiveImmediateScheduler<__covariant State> : NSObject

- (nonnull instancetype)initWithActon:(RxRecursiveImmediateAction)action andScheduler:(nonnull id <RxImmediateSchedulerType>)scheduler;

/**
 * Schedules an action to be executed recursively.
 * @param state: State passed to the action to be executed.
 */
- (void)schedule:(nonnull State)state;

- (void)dispose;

@end

NS_ASSUME_NONNULL_END