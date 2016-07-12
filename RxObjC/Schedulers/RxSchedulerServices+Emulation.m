//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSchedulerServices+Emulation.h"
#import "RxSchedulerType.h"
#import "RxObjCCommon.h"
#import "RxRecursiveScheduler.h"

@implementation RxSchedulePeriodicRecursive {
    id <RxSchedulerType> __nonnull _scheduler;
    RxTimeInterval _startAfter;
    RxTimeInterval _period;
    RxRecursiveAction _action;
    id __nonnull _state;
    int32_t _pendingTickCount;
}

- (nonnull instancetype)initWithScheduler:(nonnull id <RxSchedulerType>)scheduler
                               startAfter:(RxTimeInterval)startAfter
                                   period:(RxTimeInterval)period
                                   action:(RxRecursiveAction)action
                                    state:(nonnull id)state {
    self = [super init];
    if (self) {
        _pendingTickCount = 0;
        _scheduler = scheduler;
        _startAfter = startAfter;
        _period = period;
        _action = action;
        _state = state;
    }
    return self;
}

- (nonnull id <RxDisposable>)start {
    @weakify(self);
    NSObject *_s = _scheduler;
    return [_s scheduleRecursive:@(RxSchedulePeriodicRecursiveCommandTick) dueTime:_startAfter action:^(id state, RxAnyRecursiveScheduler *scheduler) {
        @strongify(self);
        [self tick:state scheduler:scheduler];
    }];
}

- (void)tick:(nonnull NSNumber *)commandAsNumber scheduler:(nonnull RxAnyRecursiveScheduler *)scheduler {
    // Tries to emulate periodic scheduling as best as possible.
    // The problem that could arise is if handling periodic ticks take too long, or
    // tick interval is short.

    RxSchedulePeriodicRecursiveCommand command = (RxSchedulePeriodicRecursiveCommand) [commandAsNumber unsignedIntegerValue];
    if (command == RxSchedulePeriodicRecursiveCommandTick) {
        [scheduler schedule:@(RxSchedulePeriodicRecursiveCommandTick) dueTime:_period];

        // The idea is that if on tick there wasn't any item enqueued, schedule to perform work immediatelly.
        // Else work will be scheduled after previous enqueued work completes.
        if (OSAtomicIncrement32(&_pendingTickCount) == 1) {
            [self tick:@(RxSchedulePeriodicRecursiveCommandDispatchStart) scheduler:scheduler];
        }
    } else {
        _state = _action(_state);
        // Start work and schedule check is this last batch of work
        if (OSAtomicDecrement32(&_pendingTickCount) > 0) {
            // This gives priority to scheduler emulation, it's not perfect, but helps
            [scheduler schedule:@(RxSchedulePeriodicRecursiveCommandDispatchStart)];
        }
    }
}

@end
