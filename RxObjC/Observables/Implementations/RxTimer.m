//
//  RxTimer
//  RxObjC
// 
//  Created by Pavel Malkov on 08.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTimer.h"
#import "RxSchedulerType.h"
#import "RxSink.h"
#import "RxNopDisposable.h"

@interface RxTimerSink<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxTimerSink {
    RxTimer *__nonnull _parent;
}

- (nonnull instancetype)initWithParent:(nonnull RxTimer *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
    }
    return self;
}

- (nonnull id <RxDisposable>)run {
    return [_parent->_scheduler schedulePeriodic:@0 startAfter:_parent->_dueTime period:_parent->_period action:^NSNumber *(NSNumber *__nonnull state) {
        [self forwardOn:[RxEvent next:state]];
        return @(state.intValue + 1);
    }];
}

@end
@interface RxTimerOneOffSink<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxTimerOneOffSink {
    RxTimer *__nonnull _parent;
}

- (nonnull instancetype)initWithParent:(nonnull RxTimer *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
    }
    return self;
}

- (nonnull id <RxDisposable>)run {
    return [_parent->_scheduler scheduleRelative:nil dueTime:_parent->_dueTime action:^id <RxDisposable>(id _) {
        [self forwardOn:[RxEvent next:@0]];
        [self forwardOn:[RxEvent completed]];

        return [RxNopDisposable sharedInstance];
    }];
}

@end

@implementation RxTimer

- (nonnull instancetype)initWithDueTime:(RxTimeInterval)aDueTime scheduler:(nonnull id <RxSchedulerType>)aScheduler {
    return [self initWithDueTime:aDueTime period:-1 scheduler:aScheduler];
}

- (nonnull instancetype)initWithDueTime:(RxTimeInterval)aDueTime period:(RxTimeInterval)aPeriod scheduler:(nonnull id <RxSchedulerType>)aScheduler {
    self = [super init];
    if (self) {
        _dueTime = aDueTime;
        _period = aPeriod;
        _scheduler = aScheduler;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    if (_period >= 0) {
        RxTimerSink *sink = [[RxTimerSink alloc] initWithParent:self observer:observer];
        sink.disposable = [sink run];
        return sink;
    } else {
        RxTimerOneOffSink *sink = [[RxTimerOneOffSink alloc] initWithParent:self observer:observer];
        sink.disposable = [sink run];
        return sink;
    }
}

@end