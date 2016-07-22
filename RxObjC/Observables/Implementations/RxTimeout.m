//
//  RxTimeout
//  RxObjC
// 
//  Created by Pavel Malkov on 09.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTimeout.h"
#import "RxSink.h"
#import "RxSerialDisposable.h"
#import "RxObservable+Extension.h"
#import "RxStableCompositeDisposable.h"
#import "RxNopDisposable.h"

@interface RxTimeoutSink<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxTimeoutSink {
    RxTimeout *__nonnull _parent;
    RxSerialDisposable *__nonnull _timerD;
    RxSerialDisposable *__nonnull _subscription;
    NSInteger _id;
    BOOL _switched;
}

- (nonnull instancetype)initWithParent:(nonnull RxTimeout *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _timerD = [[RxSerialDisposable alloc] init];
        _subscription = [[RxSerialDisposable alloc] init];
        _id = 0;
        _switched = NO;
        _parent = parent;
    }
    return self;
}

- (nonnull id <RxDisposable>)run {
    RxSingleAssignmentDisposable *original = [[RxSingleAssignmentDisposable alloc] init];
    _subscription.disposable = original;
    [self _createTimeoutTimer];

    original.disposable = [_parent->_source subscribeSafe:self];

    return [RxStableCompositeDisposable createDisposable1:_subscription disposable2:_timerD];
}

- (void)on:(nonnull RxEvent *)event {
    if (event.type == RxEventTypeNext) {
        __block BOOL onNextWins = NO;
        [_lock performLock:^{
            onNextWins = !_switched;
            if (onNextWins) {
                _id++;
            }
        }];
        if (onNextWins) {
            [self forwardOn:event];
            [self _createTimeoutTimer];
        } 
    } else {
        __block BOOL onEventWins = NO;

        [_lock performLock:^{
            onEventWins = !_switched;
            if (onEventWins) {
                _id++;
            }
        }];
        if (onEventWins) {
            [self forwardOn:event];
            [self dispose];
        }
    }
}

- (void)_createTimeoutTimer {
    if (_timerD.disposed) {
        return;
    }

    RxSingleAssignmentDisposable *nextTimer = [[RxSingleAssignmentDisposable alloc] init];
    _timerD.disposable = nextTimer;

    nextTimer.disposable = [_parent->_scheduler scheduleRelative:@(_id) dueTime:_parent->_dueTime action:^id <RxDisposable>(NSNumber *state) {
        __block BOOL timerWins = NO;

        [self->_lock performLock:^{
            self->_switched = state.integerValue == self->_id;
            timerWins = self->_switched;
        }];

        if (timerWins) {
            self->_subscription.disposable = [self->_parent->_other subscribeSafe:[self forwarder]];
        }

        return [RxNopDisposable sharedInstance];
    }];
}

@end

@implementation RxTimeout

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source
                               dueTime:(RxTimeInterval)dueTime
                                 other:(nonnull RxObservable<id> *)other
                             scheduler:(nonnull id <RxSchedulerType>)scheduler {
    self = [super init];
    if (self) {
        _source = source;
        _dueTime = dueTime;
        _other = other;
        _scheduler = scheduler;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxTimeoutSink *sink = [[RxTimeoutSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end