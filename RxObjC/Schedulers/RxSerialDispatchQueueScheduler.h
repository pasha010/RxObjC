//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxSchedulerType.h"

@class RxDispatchQueueSchedulerQOS;

NS_ASSUME_NONNULL_BEGIN

/**
Abstracts the work that needs to be performed on a specific `dispatch_queue_t`. It will make sure
that even if concurrent dispatch queue is passed, it's transformed into a serial one.

It is extremely important that this scheduler is serial, because
certain operator perform optimizations that rely on that property.

Because there is no way of detecting is passed dispatch queue serial or
concurrent, for every queue that is being passed, worst case (concurrent)
will be assumed, and internal serial proxy dispatch queue will be created.

This scheduler can also be used with internal serial queue alone.

In case some customization need to be made on it before usage,
internal serial queue can be customized using `serialQueueConfiguration`
callback.
*/
@interface RxSerialDispatchQueueScheduler : NSObject <RxSchedulerType>

@property (nonnull, strong, readonly) NSDate *now;

- (nonnull instancetype)initWithSerialQueue:(nonnull dispatch_queue_t)serialQueue;

/**
 Constructs new `SerialDispatchQueueScheduler` with internal serial queue named `internalSerialQueueName`.
 
 Additional dispatch queue properties can be set after dispatch queue is created using `serialQueueConfiguration`.
 
 - parameter internalSerialQueueName: Name of internal serial dispatch queue.
 - parameter serialQueueConfiguration: Additional configuration of internal serial dispatch queue.
 */
- (nonnull instancetype)initWithInternalSerialQueueName:(nonnull NSString *)internalSerialQueueName
                               andserialQueueConfiguration:(void(^)(dispatch_queue_t))serialQueueConfiguration;

/**
 Constructs new `SerialDispatchQueueScheduler` named `internalSerialQueueName` that wraps `queue`.
 
 - parameter queue: Possibly concurrent dispatch queue used to perform work.
 - parameter internalSerialQueueName: Name of internal serial dispatch queue proxy.
 */
- (nonnull instancetype)initWithQueue:(nonnull dispatch_queue_t)queue
           andInternalSerialQueueName:(nonnull NSString *)internalSerialQueueName;

/**
 Constructs new `SerialDispatchQueueScheduler` that wraps on of the global concurrent dispatch queues.
 
 - parameter globalConcurrentQueueQOS: Identifier for global dispatch queue with specified quality of service class.
 - parameter internalSerialQueueName: Custom name for internal serial dispatch queue proxy.
 */
- (nonnull instancetype)initWithglobalConcurrentQueueQOS:(RxDispatchQueueSchedulerQOS *)globalConcurrentQueueQOS
                              andInternalSerialQueueName:(nullable  NSString *)internalSerialQueueName NS_AVAILABLE(10.10, 8.0);

+ (int64_t)convertTimeIntervalToDispatchInterval:(NSTimeInterval)timeInterval;

+ (dispatch_time_t)convertTimeIntervalToDispatchTime:(NSTimeInterval)timeInterval;

/**
Schedules an action to be executed immediatelly.

- parameter state: State passed to the action to be executed.
- parameter action: Action to be executed.
- returns: The disposable object used to cancel the scheduled action (best effort).
*/
- (nonnull id <RxDisposable>)schedule:(nonnull RxStateType)state action:(id <RxDisposable> (^)(RxStateType))action;

- (nonnull id <RxDisposable>)scheduleInternal:(nonnull RxStateType)state action:(id <RxDisposable> (^)(RxStateType))action;

/**
Schedules an action to be executed.

- parameter state: State passed to the action to be executed.
- parameter dueTime: Relative time after which to execute the action.
- parameter action: Action to be executed.
- returns: The disposable object used to cancel the scheduled action (best effort).
*/
- (nonnull id <RxDisposable>)scheduleRelative:(nonnull id)state dueTime:(RxTimeInterval)dueTime action:(id <RxDisposable>(^)(id))action;

@end

NS_ASSUME_NONNULL_END