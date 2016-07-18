//
//  RxConcurrentDispatchQueueScheduler
//  RxObjC
// 
//  Created by Pavel Malkov on 14.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxConcurrentDispatchQueueScheduler.h"
#import "RxDispatchQueueSchedulerQOS.h"
#import "RxSingleAssignmentDisposable.h"
#import "RxMainScheduler.h"
#import "RxCompositeDisposable.h"
#import "RxAnonymousDisposable.h"


@implementation RxConcurrentDispatchQueueScheduler {
    dispatch_queue_t _queue;
    uint64_t _leeway;
}

- (nonnull instancetype)initWithGlobalConcurrentQueueQOS:(nonnull RxDispatchQueueSchedulerQOS *)globalConcurrentQueueQOS {
    qos_class_t priority = globalConcurrentQueueQOS.QOSClass;
    return [self initWithQueue:dispatch_get_global_queue(priority, 0)];
}

- (nonnull instancetype)initWithQueue:(dispatch_queue_t)queue {
    self = [super init];
    if (self) {
        _queue = queue;
    }

    return self;
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

- (nonnull id <RxDisposable>)schedule:(nullable RxStateType)state action:(nonnull id <RxDisposable> (^)(RxStateType __nullable))action {
    return [self scheduleInternal:state action:action];
}

- (nonnull id <RxDisposable>)scheduleInternal:(nullable RxStateType)state action:(nonnull id <RxDisposable> (^)(RxStateType __nullable))action {
    RxSingleAssignmentDisposable *cancel = [[RxSingleAssignmentDisposable alloc] init];

    dispatch_async(_queue, ^{
        if (cancel.disposed) {
            return;
        }
        cancel.disposable = action(state);
    });

    return cancel;
}

- (nonnull id <RxDisposable>)scheduleRelative:(nullable id)state dueTime:(RxTimeInterval)dueTime action:(id <RxDisposable>(^)(id))action {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);

    dispatch_time_t dispatchInterval = [RxMainScheduler convertTimeIntervalToDispatchTime:dueTime];

    RxCompositeDisposable *compositeDisposable = [[RxCompositeDisposable alloc] init];

    dispatch_source_set_timer(timer, dispatchInterval, DISPATCH_TIME_FOREVER, 0);

    dispatch_source_set_event_handler(timer, ^{
        if (compositeDisposable.disposed) {
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

- (nonnull id <RxDisposable>)schedulePeriodic:(nullable id)state
                                   startAfter:(RxTimeInterval)startAfter
                                       period:(RxTimeInterval)period
                                       action:(id(^)(id __nullable ))action {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);

    dispatch_time_t initial = [RxMainScheduler convertTimeIntervalToDispatchTime:startAfter];
    int64_t dispatchInterval = [RxMainScheduler convertTimeIntervalToDispatchInterval:period];
    
    __block id timerState = state;

    uint64_t validDispatchInterval = dispatchInterval < 0 ? 0 : ((uint64_t) dispatchInterval);

    dispatch_source_set_timer(timer, initial, validDispatchInterval, 0);
    RxAnonymousDisposable *cancel = [[RxAnonymousDisposable alloc] initWithDisposeAction:^{
        dispatch_source_cancel(timer);
    }];

    dispatch_source_set_event_handler(timer, ^{
        if (cancel.disposed) {
            return;
        }
        timerState = action(timerState);
    });
    dispatch_resume(timer);
    return cancel;
}


@end