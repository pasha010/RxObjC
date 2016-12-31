//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxImmediateSchedulerType.h"
#import "RxMutableBox.h"
#import "RxQueue.h"

@protocol RxScheduledItemType;

NS_ASSUME_NONNULL_BEGIN

@interface RxCurrentThreadSchedulerKey : NSObject <NSCopying>
@end

@interface RxCurrentThreadSchedulerQueueKey : NSObject <NSCopying>
@end

/**
 * Represents an object that schedules units of work on the current thread.
 * This is the default scheduler for operators that generate elements.
 * This scheduler is also sometimes called `trampoline scheduler`.
 */
@interface RxCurrentThreadScheduler : RxImmediateScheduler

@property (nullable, strong) RxMutableBox<RxQueue<id <RxScheduledItemType>> *> *queue;

/** Gets a value that indicates whether the caller must call a `schedule` method. */
@property (assign, readonly) BOOL isScheduleRequired;

+ (nonnull instancetype)sharedInstance;

/**
 * Schedules an action to be executed as soon as possible on current thread.
 *
 * If this method is called on some thread that doesn't have `CurrentThreadScheduler` installed, scheduler will be
 * automatically installed and uninstalled after all work is performed.
 * @param state: State passed to the action to be executed.
 * @param action: Action to be executed.
 * @return: The disposable object used to cancel the scheduled action (best effort).
 */
- (nonnull id <RxDisposable>)schedule:(nullable RxStateType)state action:(id <RxDisposable> (^)(RxStateType))action;

@end

NS_ASSUME_NONNULL_END