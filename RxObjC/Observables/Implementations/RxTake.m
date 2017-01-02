//
//  RxTake
//  RxObjC
// 
//  Created by Pavel Malkov on 02.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTake.h"
#import "RxSink.h"
#import "RxSynchronizedOnType.h"
#import "RxNopDisposable.h"
#import "RxBinaryDisposable.h"
#import "RxLockOwnerType.h"

@interface RxTakeCountSink<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxTakeCountSink {
    RxTakeCount *__nonnull _parent;
    NSUInteger _remaining;
}

- (nonnull instancetype)initWithParent:(nonnull RxTakeCount *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
        _remaining = _parent->_count;
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    if (event.type == RxEventTypeNext) {
        if (_remaining > 0) {
            _remaining--;
            [self forwardOn:[RxEvent next:event.element]];

            if (_remaining == 0) {
                [self forwardOn:[RxEvent completed]];
                [self dispose];
            }
        }
    } else {
        [self forwardOn:event];
        [self dispose];
    }
}

@end

@implementation RxTakeCount

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source count:(NSUInteger)count {
    self = [super init];
    if (self) {
        _source = source;
        _count = count;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxTakeCountSink *sink = [[RxTakeCountSink alloc] initWithParent:self observer:observer];
    sink.disposable = [_source subscribe:sink];
    return sink;
}

@end

@interface RxTakeTimeSink<O : id<RxObserverType>> : RxSink<O> <RxLockOwnerType, RxObserverType, RxSynchronizedOnType>
@end

@implementation RxTakeTimeSink {
    RxTakeTime *__nonnull _parent;
}

- (nonnull instancetype)initWithParent:(nonnull RxTakeTime *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
    }
    return self;
}

- (nonnull RxSpinLock *)lock {
    return _lock;
}

- (void)on:(nonnull RxEvent *)event {
    rx_synchronizedOn(self, event);
}

- (void)_synchronized_on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            [self forwardOn:[RxEvent next:event.element]];
            break;
        }
        case RxEventTypeError: {
            [self forwardOn:event];
            [self dispose];
            break;
        }
        case RxEventTypeCompleted: {
            [self forwardOn:event];
            [self dispose];
            break;
        }
    }
}

- (void)tick {
    [_lock lock];
    
    [self forwardOn:[RxEvent completed]];
    [self dispose];
    
    [_lock unlock];
}

- (nonnull id <RxDisposable>)run {
    id <RxDisposable> disposeTimer = [_parent->_scheduler scheduleRelative:nil dueTime:_parent->_duration action:^id <RxDisposable>(id _) {
        [self tick];
        return [RxNopDisposable sharedInstance];
    }];
    id <RxDisposable> disposeSubscription = [_parent->_source subscribe:self];
    return [[RxBinaryDisposable alloc] initWithFirstDisposable:disposeTimer andSecondDisposable:disposeSubscription];
}

@end

@implementation RxTakeTime

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source
                              duration:(RxTimeInterval)duration
                             scheduler:(nonnull id <RxSchedulerType>)scheduler {
    self = [super init];
    if (self) {
        _source = source;
        _duration = duration;
        _scheduler = scheduler;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxTakeTimeSink *sink = [[RxTakeTimeSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end