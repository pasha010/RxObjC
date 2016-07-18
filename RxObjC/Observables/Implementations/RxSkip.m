//
//  RxSkip
//  RxObjC
// 
//  Created by Pavel Malkov on 02.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSkip.h"
#import "RxSink.h"
#import "RxNopDisposable.h"
#import "RxBinaryDisposable.h"

@interface RxSkipCountSink<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxSkipCountSink {
    RxSkipCount *__nonnull _parent;
    NSUInteger _remaining;
}

- (nonnull instancetype)initWithParent:(nonnull RxSkipCount *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _remaining = parent->_count;
        _parent = parent;
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    if (event.type == RxEventTypeNext) {
        if (_remaining == 0) {
            [self forwardOn:[RxEvent next:event.element]];
        } else {
            _remaining--;
        }
    } else {
        [self forwardOn:event];
        [self dispose];
    }
}

@end

@implementation RxSkipCount

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source count:(NSUInteger)count {
    self = [super init];
    if (self) {
        _source = source;
        _count = count;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxSkipCountSink *sink = [[RxSkipCountSink alloc] initWithParent:self observer:observer];
    sink.disposable = [_source subscribe:sink];
    return sink;
}

@end

@interface RxSkipTimeSink<O : id<RxObserverType>> : RxSink<O> <RxObserverType>
@end

@implementation RxSkipTimeSink {
    RxSkipTime *__nonnull _parent;
    BOOL _open;
}

- (nonnull instancetype)initWithParent:(nonnull RxSkipTime *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _open = NO;
        _parent = parent;
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            if (_open) {
                [self forwardOn:[RxEvent next:event.element]];
            }
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
    _open = YES;
}

- (nonnull id <RxDisposable>)run {
    @weakify(self);
    id <RxDisposable> disposeTimer = [_parent->_scheduler scheduleRelative:nil dueTime:_parent->_duration action:^id <RxDisposable>(id _) {
        @strongify(self);
        [self tick];
        return [RxNopDisposable sharedInstance];
    }];
    id <RxDisposable> disposeSubscription = [_parent->_source subscribe:self];
    return [[RxBinaryDisposable alloc] initWithFirstDisposable:disposeTimer andSecondDisposable:disposeSubscription];
}

@end

@implementation RxSkipTime

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
    RxSkipTimeSink *sink = [[RxSkipTimeSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end