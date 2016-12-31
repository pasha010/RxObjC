//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxImmediateSchedulerType.h"

@class RxDispatchQueueSchedulerQOS;

NS_ASSUME_NONNULL_BEGIN

/**
 * Abstracts the work that needs to be performed on a specific `dispatch_queue_t`. It will make sure
 * that even if concurrent dispatch queue is passed, it's transformed into a serial one.
 *
 * It is extremely important that this scheduler is serial, because
 * certain operator perform optimizations that rely on that property.
 *
 * Because there is no way of detecting is passed dispatch queue serial or
 * concurrent, for every queue that is being passed, worst case (concurrent)
 * will be assumed, and internal serial proxy dispatch queue will be created.
 *
 * This scheduler can also be used with internal serial queue alone.
 *
 * In case some customization need to be made on it before usage,
 * internal serial queue can be customized using `serialQueueConfiguration`
 * callback.
 */
@interface RxSerialDispatchQueueScheduler : RxScheduler

@property (nonnull, strong, readonly) NSDate *now;

- (nonnull instancetype)initWithSerialQueue:(nonnull dispatch_queue_t)serialQueue NS_DESIGNATED_INITIALIZER;

/**
 * Constructs new `SerialDispatchQueueScheduler` with internal serial queue named `internalSerialQueueName`.
 *
 * Additional dispatch queue properties can be set after dispatch queue is created using `serialQueueConfiguration`.
 * @param internalSerialQueueName: Name of internal serial dispatch queue.
 * @param serialQueueConfiguration: Additional configuration of internal serial dispatch queue.
 * @return: RxSerialDispatchQueueScheduler instance
 */
- (nonnull instancetype)initWithInternalSerialQueueName:(nonnull NSString *)internalSerialQueueName
                               andSerialQueueConfiguration:(nullable void(^)(dispatch_queue_t queue))serialQueueConfiguration;

- (nonnull instancetype)initWithInternalSerialQueueName:(nonnull NSString *)internalSerialQueueName;

/**
 * Constructs new `SerialDispatchQueueScheduler` named `internalSerialQueueName` that wraps `queue`.
 * @param queue: Possibly concurrent dispatch queue used to perform work.
 * @param internalSerialQueueName: Name of internal serial dispatch queue proxy.
 * @return: RxSerialDispatchQueueScheduler instance
 */
- (nonnull instancetype)initWithQueue:(nonnull dispatch_queue_t)queue
           andInternalSerialQueueName:(nonnull NSString *)internalSerialQueueName;

/**
 * Constructs new `SerialDispatchQueueScheduler` that wraps on of the global concurrent dispatch queues.
 *
 * @param globalConcurrentQueueQOS: Identifier for global dispatch queue with specified quality of service class.
 * @param internalSerialQueueName: Custom name for internal serial dispatch queue proxy.
 * @return: RxSerialDispatchQueueScheduler instance
 */
- (nonnull instancetype)initWithGlobalConcurrentQueueQOS:(RxDispatchQueueSchedulerQOS *)globalConcurrentQueueQOS
                              andInternalSerialQueueName:(nullable  NSString *)internalSerialQueueName NS_AVAILABLE(10_10, 8_0);

/**
 * Constructs new `SerialDispatchQueueScheduler` that wraps on of the global concurrent dispatch queues.
 *
 * @param globalConcurrentQueueQOS: Identifier for global dispatch queue with specified quality of service class.
 * @return: RxSerialDispatchQueueScheduler instance
 */
- (nonnull instancetype)initWithGlobalConcurrentQueueQOS:(RxDispatchQueueSchedulerQOS *)globalConcurrentQueueQOS NS_AVAILABLE(10_10, 8_0);

+ (int64_t)convertTimeIntervalToDispatchInterval:(NSTimeInterval)timeInterval;

+ (dispatch_time_t)convertTimeIntervalToDispatchTime:(NSTimeInterval)timeInterval;

/**
 * Schedules an action to be executed immediatelly.
 *
 * @param state: State passed to the action to be executed.
 * @param action: Action to be executed.
 * @return: The disposable object used to cancel the scheduled action (best effort).
*/
- (nonnull id <RxDisposable>)schedule:(nullable RxStateType)state action:(nonnull id <RxDisposable> (^)(RxStateType __nullable _state))action;

- (nonnull id <RxDisposable>)scheduleInternal:(nonnull RxStateType)state action:(nonnull id <RxDisposable> (^)(RxStateType __nullable _state))action;

/**
 * Schedules an action to be executed.
 *
 * @param state: State passed to the action to be executed.
 * @param dueTime: Relative time after which to execute the action.
 * @param action: Action to be executed.
 * @return: The disposable object used to cancel the scheduled action (best effort).
*/
- (nonnull id <RxDisposable>)scheduleRelative:(nullable id)state dueTime:(RxTimeInterval)dueTime action:(id <RxDisposable>(^)(RxStateType __nullable _state))action;

@end

NS_ASSUME_NONNULL_END