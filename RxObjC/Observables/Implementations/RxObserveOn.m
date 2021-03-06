//
//  RxObserveOn
//  RxObjC
// 
//  Created by Pavel Malkov on 26.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObserveOn.h"
#import "RxImmediateSchedulerType.h"
#import "RxObserverBase.h"
#import "RxLock.h"
#import "RxQueue.h"
#import "RxSerialDisposable.h"
#import "RxSingleAssignmentDisposable.h"
#import "RxTuple.h"

typedef NS_ENUM(NSUInteger, RxObserveOnState) {
    /// pump is not running
    RxObserveOnStateStopped = 0,
    /// pump is running
    RxObserveOnStateRunning = 1,
};

@interface RxObserveOnSink<O : id<RxObserverType>> : RxObserverBase {
@package
    RxSingleAssignmentDisposable *__nonnull _subscription;
@private
    RxImmediateScheduler *__nonnull _scheduler;
    id <RxObserverType> __nullable _observer;
    RxSpinLock *__nonnull _lock;
    RxQueue<RxEvent *> *__nonnull _queue;
    RxObserveOnState _state;
    RxSerialDisposable *__nonnull _scheduleDisposable;
}
@end

@implementation RxObserveOnSink

- (nonnull instancetype)initWithScheduler:(nonnull RxImmediateScheduler *)scheduler observer:(nonnull id <RxObserverType>)observer {
    self = [super init];
    if (self) {
        _lock = [[RxSpinLock alloc] init];
        _state = RxObserveOnStateStopped;
        _queue = [[RxQueue alloc] initWithCapacity:10];
        _scheduleDisposable = [[RxSerialDisposable alloc] init];
        _subscription = [[RxSingleAssignmentDisposable alloc] init];
        
        _scheduler = scheduler;
        _observer = observer;
    }
    return self;
}

- (void)_onCore:(nonnull RxEvent *)event {
    BOOL shouldStart = ((NSNumber *) [_lock calculateLocked:^NSNumber * {
        [_queue enqueue:event];
        if (_state == RxObserveOnStateStopped) {
            _state = RxObserveOnStateRunning;
            return @YES;
        } else {
            return @NO;
        }
    }]).boolValue;

    if (shouldStart) {
        _scheduleDisposable.disposable = [_scheduler scheduleRecursive:nil action:^(id o, void (^recurse)(id)) {
            [self run:o recurse:recurse];
        }];
    }
}

#pragma clang diagnostic push
#pragma ide diagnostic ignored "NotSuperclass"
#pragma ide diagnostic ignored "NotImplementsProtocol"
- (void)run:(__unused id)state recurse:(void (^)(id))recurse {
    RxTuple2<RxEvent *, id <RxObserverType>> *tuple = [_lock calculateLocked:^RxTuple2<RxEvent *, id <RxObserverType>> *{
        id <RxObserverType> observer = _observer;
        if (_queue.count > 0) {
            RxEvent *event = [_queue dequeue];
            return [RxTuple2 tupleWithArray:@[event ?: [RxNil null], observer ?: [RxNil null]]];
        } else {
            _state = RxObserveOnStateStopped;
            return [RxTuple2 tupleWithArray:@[[RxNil null], observer ?: [RxNil null]]];
        }
    }];
    RxEvent *nextEvent = tuple.first;
    if (nextEvent == [RxNil null]) {
        nextEvent = nil;
    }

    id <RxObserverType> observer = tuple.second;
    if (observer == [RxNil null]) {
        observer = nil;
    }

    if (nextEvent) {
        [observer on:nextEvent];
        if (nextEvent.isStopEvent) {
            [self dispose];
        }
    } else {
        return;
    }

    BOOL shouldContinue = [self _shouldContinue_synchronized];
    if (shouldContinue) {
        recurse(nil);
    }
}
#pragma clang diagnostic pop

- (BOOL)_shouldContinue_synchronized {
    NSNumber *result = [_lock calculateLocked:^NSNumber * {
        if (_queue.count > 0) {
            return @YES;
        } else {
            _state = RxObserveOnStateStopped;
            return @NO;
        }
    }];

    return result.boolValue;
}

- (void)dispose {
    [super dispose];

    [_subscription dispose];
    [_scheduleDisposable dispose];

    [_lock performLock:^{
        _observer = nil;
    }];
}

@end

@implementation RxObserveOn {
    RxImmediateScheduler *__nonnull _scheduler;
    RxObservable *__nonnull _source;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source
                             scheduler:(nonnull RxImmediateScheduler *)scheduler {
    self = [super init];
    if (self) {
        _scheduler = scheduler;
        _source = source;
#if TRACE_RESOURCES
        OSAtomicIncrement32(&rx_resourceCount);
#endif
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxObserveOnSink *sink = [[RxObserveOnSink alloc] initWithScheduler:_scheduler observer:observer];
    sink->_subscription.disposable = [_source subscribe:sink];
    return sink;
}

#if TRACE_RESOURCES
- (void)dealloc {
    OSAtomicDecrement32(&rx_resourceCount);
}
#endif

@end