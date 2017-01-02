//
//  RxWindow
//  RxObjC
// 
//  Created by Pavel Malkov on 09.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxWindow.h"
#import "RxSink.h"
#import "RxLockOwnerType.h"
#import "RxSynchronizedOnType.h"
#import "RxPublishSubject.h"
#import "RxSerialDisposable.h"
#import "RxRefCountDisposable.h"
#import "RxCompositeDisposable.h"
#import "RxAddRef.h"
#import "RxNopDisposable.h"

@interface RxWindowTimeCountSink<Element, O : id <RxObserverType>> : RxSink<O> <RxLockOwnerType, RxObserverType, RxSynchronizedOnType>
@end

@implementation RxWindowTimeCountSink {
    RxWindowTimeCount *__nonnull _parent;
    RxPublishSubject *__nonnull _subject;
    NSUInteger _count;
    NSInteger _windowId;
    RxSerialDisposable *__nonnull _timerD;
    RxRefCountDisposable *__nonnull _refCountDisposable;
    RxCompositeDisposable *__nonnull _groupDisposable;
}

- (nonnull instancetype)initWithParent:(nonnull RxWindowTimeCount *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _subject = [RxPublishSubject create];
        _count = 0;
        _windowId = 0;
        _timerD = [[RxSerialDisposable alloc] init];
        _groupDisposable = [[RxCompositeDisposable alloc] init];
        _parent = parent;

        _refCountDisposable = [[RxRefCountDisposable alloc] initWithDisposable:_groupDisposable];
        [_groupDisposable addDisposable:_timerD];
    }
    return self;
}

- (nonnull id <RxDisposable>)run {
    RxObservable *value = [[[RxAddRef alloc] initWithSource:_subject refCount:_refCountDisposable] asObservable];
    [self forwardOn:[RxEvent next:value]];
    [self createTimer:_windowId];

    [_groupDisposable addDisposable:[_parent->_source subscribeSafe:self]];
    return _refCountDisposable;
}

- (void)startNewWindowAndCompleteCurrentOne {
    [_subject on:[RxEvent completed]];
    _subject = [RxPublishSubject create];
    RxObservable *value = [[[RxAddRef alloc] initWithSource:_subject refCount:_refCountDisposable] asObservable];
    [self forwardOn:[RxEvent next:value]];
}

- (void)rx_lock {
    [[self getRxLock] lock];
}

- (void)rx_unlock {
    [[self getRxLock] unlock];
}

- (nonnull RxSpinLock *)getRxLock {
    return _lock;
}

- (void)on:(nonnull RxEvent *)event {
    rx_synchronizedOn(self, event);
}

- (void)_synchronized_on:(nonnull RxEvent *)event {
    BOOL newWindow = NO;
    NSInteger newId = 0;

    switch (event.type) {
        case RxEventTypeNext: {
            [_subject on:[RxEvent next:event.element]];

            rx_tryCatch(^{
                rx_incrementCheckedUnsigned(&_count);
            }, ^(NSError *error) {
                [_subject on:[RxEvent error:error]];
                [self dispose];
            });

            if (_count == _parent->_count) {
                newWindow = YES;
                _count = 0;
                _windowId++;
                newId = _windowId;
                [self startNewWindowAndCompleteCurrentOne];
            }
            break;
        }
        case RxEventTypeError: {
            [_subject on:[RxEvent error:event.error]];
            [self forwardOn:[RxEvent error:event.error]];
            [self dispose];
            break;
        }
        case RxEventTypeCompleted: {
            [_subject on:[RxEvent completed]];
            [self forwardOn:[RxEvent completed]];
            [self dispose];
            break;
        }
    }
    if (newWindow) {
        [self createTimer:newId];
    }
}

- (void)createTimer:(NSInteger)windowId {
    if (_timerD.disposed) {
        return;
    }

    if (_windowId != windowId) {
        return;
    }

    RxSingleAssignmentDisposable *nextTimer = [[RxSingleAssignmentDisposable alloc] init];

    _timerD.disposable = nextTimer;

    nextTimer.disposable = [_parent->_scheduler scheduleRelative:@(windowId) dueTime:_parent->_timeSpan action:^id <RxDisposable>(NSNumber *prevWindowId) {
        NSUInteger previousWindowId = prevWindowId.unsignedIntegerValue;
        __block NSInteger newId = 0;

        [self->_lock performLock:^{
            if (previousWindowId != self->_windowId) {
                return;
            }
            self->_count = 0;
            self->_windowId++;
            newId = self->_windowId;
            [self startNewWindowAndCompleteCurrentOne];
        }];

        [self createTimer:newId];

        return [RxNopDisposable sharedInstance];
    }];
}

@end

@implementation RxWindowTimeCount

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source timeSpan:(RxTimeInterval)timeSpan count:(NSUInteger)count scheduler:(nonnull id <RxSchedulerType>)scheduler {
    self = [super init];
    if (self) {
        _source = source;
        _timeSpan = timeSpan;
        _count = count;
        _scheduler = scheduler;
    }

    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxWindowTimeCountSink *sink = [[RxWindowTimeCountSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end