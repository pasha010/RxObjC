//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSerialDispatchQueueScheduler.h"
#import "RxDispatchQueueSchedulerQOS.h"
#import "RxSingleAssignmentDisposable.h"
#import "RxMainScheduler.h"
#import "RxCompositeDisposable.h"
#import "RxAnonymousDisposable.h"


static NSString *const RxGlobalDispatchQueueName = @"rx.global_dispatch_queue.serial";

@implementation RxSerialDispatchQueueScheduler {
    dispatch_queue_t __nonnull _serialQueue;
    // leeway for scheduling timers
    int64_t _leeway;
}

- (nonnull instancetype)initWithSerialQueue:(dispatch_queue_t)serialQueue {
    self = [super init];
    if (self) {
        _leeway = 0;
        _serialQueue = serialQueue;
    }
    return self;
}

- (nonnull instancetype)initWithInternalSerialQueueName:(nonnull NSString *)internalSerialQueueName
                            andserialQueueConfiguration:(void(^)(dispatch_queue_t))serialQueueConfiguration {
    dispatch_queue_t queue = dispatch_queue_create([internalSerialQueueName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
    serialQueueConfiguration(queue);
    return [self initWithSerialQueue:queue];
}

- (nonnull instancetype)initWithQueue:(nonnull dispatch_queue_t)queue
           andInternalSerialQueueName:(nonnull NSString *)internalSerialQueueName {
    dispatch_queue_t serialQueue = dispatch_queue_create([internalSerialQueueName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(serialQueue, queue);
    return [self initWithSerialQueue:serialQueue];
}

- (nonnull instancetype)initWithglobalConcurrentQueueQOS:(RxDispatchQueueSchedulerQOS *)globalConcurrentQueueQOS
                              andInternalSerialQueueName:(nullable NSString *)internalSerialQueueName {
    NSString *queueName = internalSerialQueueName ?: RxGlobalDispatchQueueName;
    qos_class_t priority = globalConcurrentQueueQOS.QOSClass;
    return [self initWithQueue:dispatch_get_global_queue(priority, 0) andInternalSerialQueueName:queueName];
}

- (nonnull NSDate *)now {
    return [NSDate date];
}

+ (int64_t)convertTimeIntervalToDispatchInterval:(NSTimeInterval)timeInterval {
    return (int64_t) (timeInterval * ((double) NSEC_PER_SEC));
}

+ (dispatch_time_t)convertTimeIntervalToDispatchTime:(NSTimeInterval)timeInterval {
    return dispatch_time(DISPATCH_TIME_NOW, [self convertTimeIntervalToDispatchInterval:timeInterval]);
}

- (nonnull id <RxDisposable>)schedule:(nonnull RxStateType)state action:(id <RxDisposable> (^)(RxStateType))action {
    return [self scheduleInternal:state action:action];
}

- (nonnull id <RxDisposable>)scheduleInternal:(nonnull RxStateType)state action:(id <RxDisposable> (^)(RxStateType))action {
    __block RxSingleAssignmentDisposable *cancel = [[RxSingleAssignmentDisposable alloc] init];
    dispatch_async(_serialQueue, ^{
        if ([cancel disposed]) {
            return;
        }
        cancel.disposable = action(state);
    });
    return cancel;
}

- (nonnull id <RxDisposable>)scheduleRelative:(nullable id)state dueTime:(RxTimeInterval)dueTime action:(id <RxDisposable>(^)(id))action {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _serialQueue);
    
    dispatch_time_t dispatchInterval = [RxMainScheduler convertTimeIntervalToDispatchTime:dueTime];

    __block RxCompositeDisposable *compositeDisposable = [[RxCompositeDisposable alloc] init];

    dispatch_source_set_timer(timer, dispatchInterval, DISPATCH_TIME_FOREVER, 0);
    dispatch_source_set_event_handler(timer, ^{
        if ([compositeDisposable disposed]) {
            return;
        }
        [compositeDisposable addDisposable:action(state)];
    });

    dispatch_resume(timer);

    [compositeDisposable addDisposable:[[RxAnonymousDisposable alloc] initWithDisposeAction:^{
        dispatch_source_cancel(timer);
    }]];

    return compositeDisposable;
}

/**
Schedules a periodic piece of work.

- parameter state: State passed to the action to be executed.
- parameter startAfter: Period after which initial work should be run.
- parameter period: Period for running the work periodically.
- parameter action: Action to be executed.
- returns: The disposable object used to cancel the scheduled action (best effort).
*/
- (nonnull id <RxDisposable>)schedulePeriodic:(nonnull id)state
                                   startAfter:(RxTimeInterval)startAfter
                                       period:(RxTimeInterval)period
                                       action:(id(^)(id))action {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _serialQueue);
    
    dispatch_time_t initial = [RxMainScheduler convertTimeIntervalToDispatchTime:startAfter];
    int64_t dispatchInterval = [RxMainScheduler convertTimeIntervalToDispatchInterval:period];
    
    __block id timerState = state;

    uint64_t validDispatchInterval = dispatchInterval < 0 ? 0 : ((uint64_t) dispatchInterval);

    dispatch_source_set_timer(timer, initial, validDispatchInterval, 0);

    __block RxAnonymousDisposable *cancel = [[RxAnonymousDisposable alloc] initWithDisposeAction:^{
        dispatch_source_cancel(timer);
    }];
    dispatch_source_set_event_handler(timer, ^{
        if ([cancel disposed]) {
            return;
        }
        timerState = action(timerState);
    });
    dispatch_resume(timer);

    return cancel;
}

@end