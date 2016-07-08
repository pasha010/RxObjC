//
//  RxBufferTimeCount
//  RxObjC
// 
//  Created by Pavel Malkov on 08.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxBufferTimeCount.h"
#import "RxSink.h"
#import "RxSynchronizedOnType.h"
#import "RxLockOwnerType.h"
#import "RxSerialDisposable.h"
#import "RxStableCompositeDisposable.h"
#import "RxNopDisposable.h"

@interface RxBufferTimeCountSink<O : id <RxObserverType>> : RxSink<O> <RxLockOwnerType, RxObserverType, RxSynchronizedOnType>
@end

@implementation RxBufferTimeCountSink {
    RxBufferTimeCount *__nonnull _parent;
    RxSerialDisposable *__nonnull _timerD;
    NSMutableArray *__nonnull _buffer;
    NSUInteger _windowID;
}

- (nonnull instancetype)initWithParent:(nonnull RxBufferTimeCount *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _timerD = [[RxSerialDisposable alloc] init];
        _buffer = [NSMutableArray array];
        _parent = parent;
        _windowID = 0;
    }
    return self;
}

- (nonnull id <RxDisposable>)run {
    [self createTimer:_windowID];
    return [RxStableCompositeDisposable createDisposable1:_timerD disposable2:[_parent->_source subscribe:self]];
}

- (void)startNewWindowAndSendCurrentOne {
    _windowID = _windowID++;
    NSUInteger windowID = _windowID;

    NSArray *buffer = [_buffer copy];

    [_buffer removeAllObjects];
    
    [self forwardOn:[RxEvent next:buffer]];
    [self createTimer:windowID];
}

- (void)on:(nonnull RxEvent *)event {
    [self synchronizedOn:event];
}

- (void)_synchronized_on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            [_buffer addObject:event.element];
            if (_buffer.count == _parent->_count) {
                [self startNewWindowAndSendCurrentOne];
            }
            break;
        }
        case RxEventTypeError: {
            [_buffer removeAllObjects];
            [self forwardOn:[RxEvent error:event.error]];
            [self dispose];
            break;
        }
        case RxEventTypeCompleted: {
            [self forwardOn:[RxEvent next:[_buffer copy]]];
            [self forwardOn:[RxEvent completed]];
            [self dispose];
            break;
        }
    }
}

- (void)createTimer:(NSUInteger)windowId {
    if (_timerD.disposed) {
        return;
    }
    
    if (_windowID != windowId) {
        return;
    }

    RxSingleAssignmentDisposable *nextTimer = [[RxSingleAssignmentDisposable alloc] init];

    _timerD.disposable = nextTimer;

    @weakify(self);
    nextTimer.disposable = [_parent->_scheduler scheduleRelative:@(windowId) dueTime:_parent->_timeSpan action:^id <RxDisposable>(NSNumber *prevWindowId) {
        @strongify(self);
        NSUInteger previousWindowID = prevWindowId.unsignedIntegerValue;
        [self->_lock performLock:^{
            if (previousWindowID != self->_windowID) {
                return;
            }
            [self startNewWindowAndSendCurrentOne];
        }];
        return [RxNopDisposable sharedInstance];
    }];
}

@end

@implementation RxBufferTimeCount

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
    RxBufferTimeCountSink *sink = [[RxBufferTimeCountSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end