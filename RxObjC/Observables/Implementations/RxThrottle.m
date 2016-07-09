//
//  RxThrottle
//  RxObjC
// 
//  Created by Pavel Malkov on 04.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxThrottle.h"
#import "RxSink.h"
#import "RxLockOwnerType.h"
#import "RxSynchronizedOnType.h"
#import "RxSerialDisposable.h"
#import "RxStableCompositeDisposable.h"
#import "RxNopDisposable.h"

@interface RxThrottleSink<O : id<RxObserverType>> : RxSink<O> <RxObserverType, RxLockOwnerType, RxSynchronizedOnType>
@end

@implementation RxThrottleSink {
    RxThrottle *__nonnull _parent;
    uint64_t _id;
    id __nullable _value;
    RxSerialDisposable *__nonnull _cancellable;
}

- (nonnull instancetype)initWithParent:(nonnull RxThrottle *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _id = 0;
        _value = nil;
        _cancellable = [[RxSerialDisposable alloc] init];
        _parent = parent;
    }
    return self;
}

- (nonnull id <RxDisposable>)run {
    id <RxDisposable> subscription = [_parent->_source subscribe:self];
    return [RxStableCompositeDisposable createDisposable1:subscription disposable2:_cancellable];
}

- (void)on:(nonnull RxEvent *)event {
    [self synchronizedOn:event];
}

- (void)_synchronized_on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            _id++;

            uint64_t currentId = _id;
            _value = event.element;

            id <RxSchedulerType> scheduler = _parent->_scheduler;
            RxTimeInterval dueTime = _parent->_dueTime;

            RxSingleAssignmentDisposable *d = [[RxSingleAssignmentDisposable alloc] init];
            _cancellable.disposable = d;
            @weakify(self);
            d.disposable = [scheduler scheduleRelative:@(currentId) dueTime:dueTime action:^id <RxDisposable>(NSNumber *o) {
                @strongify(self);
                return [self propagate:o.unsignedLongLongValue];
            }];
            
            break;
        }
        case RxEventTypeError: {
            _value = nil;
            [self forwardOn:event];
            [self dispose];
            break;
        }
        case RxEventTypeCompleted: {
            id value = _value;
            if (value) {
                _value = nil;
                [self forwardOn:[RxEvent next:value]];
            }
            [self forwardOn:[RxEvent completed]];
            [self dispose];
            break;
        }
    }
}

- (nonnull id <RxDisposable>)propagate:(uint64_t)currentId {
    [_lock lock];

    id originalValue = _value;

    if (_id == currentId) {
        _value = nil;
        [self forwardOn:[RxEvent next:originalValue]];
    }

    [_lock unlock];
    return [RxNopDisposable sharedInstance];
}

@end

@implementation RxThrottle

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source dueTime:(RxTimeInterval)dueTime scheduler:(nonnull id <RxSchedulerType>)scheduler {
    self = [super init];
    if (self) {
        _source = source;
        _dueTime = dueTime;
        _scheduler = scheduler;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxThrottleSink *sink = [[RxThrottleSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end