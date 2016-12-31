//
//  RxOperationQueueScheduler
//  RxObjC
// 
//  Created by Pavel Malkov on 15.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxImmediateSchedulerType.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Abstracts the work that needs to be performed on a specific `NSOperationQueue`.
 * This scheduler is suitable for cases when there is some bigger chunk of work that needs to be performed in background and you want to fine tune concurrent processing using `maxConcurrentOperationCount`.
 */
@interface RxOperationQueueScheduler : RxImmediateScheduler

@property (nonnull, readonly) NSOperationQueue *operationQueue;

/**
 * Constructs new instance of `OperationQueueScheduler` that performs work on `operationQueue`.
 * @param operationQueue: Operation queue targeted to perform work on.
 * @return RxOperationQueueScheduler instance
 */
- (nonnull instancetype)initWithOperationQueue:(nonnull NSOperationQueue *)operationQueue;

/**
 * Schedules an action to be executed recursively.
 * @param state: State passed to the action to be executed.
 * @param action: Action to execute recursively. The last parameter passed to the action is used to trigger recursive scheduling of the action, passing in recursive invocation state.
 * @return: The disposable object used to cancel the scheduled action (best effort).
 */
- (nonnull id <RxDisposable>)schedule:(nullable RxStateType)state action:(nonnull id <RxDisposable> (^)(RxStateType __nullable))action;

@end

NS_ASSUME_NONNULL_END