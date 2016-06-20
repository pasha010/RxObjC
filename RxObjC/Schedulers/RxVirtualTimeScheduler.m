//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxVirtualTimeScheduler.h"
#import "RxPriorityQueue.h"
#import "RxDisposable.h"
#import "RxSingleAssignmentDisposable.h"
#import "RxCompositeDisposable.h"
#import "RxMainScheduler.h"

@interface RxVirtualSchedulerItem : NSObject <RxDisposable>
@property (nonnull, strong, readonly) RxVirtualTimeUnit time;
@property (assign, readonly) NSInteger id;
@end

@implementation RxVirtualSchedulerItem {
    id <RxDisposable> (^_action)();
    RxSingleAssignmentDisposable *__nonnull _disposable;
}

- (nonnull instancetype)initWithAction:(id <RxDisposable>(^)())action time:(nonnull RxVirtualTimeUnit)time id:(NSInteger)id {
    self = [super init];
    if (self) {
        _disposable = [[RxSingleAssignmentDisposable alloc] init];
        _action = action;
        _time = time;
        _id = id;
    }
    return self;
}

- (BOOL)disposed {
    return _disposable.disposed;
}

- (void)invoke {
    _disposable.disposable = _action();
}

- (void)dispose {
    [_disposable dispose];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@", _time];
}

@end

@implementation RxVirtualTimeScheduler {
    BOOL _running;
    RxPriorityQueue<RxVirtualSchedulerItem *> *__nonnull _schedulerQueue;
    id <RxVirtualTimeConverterType> _converter;
    NSInteger _nextId;
}

- (nonnull instancetype)initWithInitialClock:(nonnull RxVirtualTimeUnit)initialClock 
                                andConverter:(nonnull id <RxVirtualTimeConverterType>)converter {
    self = [super init];
    if (self) {
        _nextId = 0;
        _clock = initialClock;
        _running = NO;
        _converter = converter;
        _schedulerQueue = [[RxPriorityQueue alloc] initWithHasHigherPriority:^BOOL(RxVirtualSchedulerItem *obj1, RxVirtualSchedulerItem *obj2) {
            RxVirtualTimeComparison *comparison = [converter compareVirtualTime:obj1.time with:obj2.time];
            if (comparison.lessThan) {
                return YES;
            }
            if (comparison.equal) {
                return [obj1 id] < [obj2 id];
            } else {
                return NO;
            }
        }];
#if TRACE_RESOURCES
        OSAtomicIncrement32(&rx_resourceCount);
#endif
    }
    return self;
}

- (nonnull RxTime *)now {
    return [_converter convertFromVirtualTime:self.clock];
}

- (nonnull id <RxDisposable>)schedule:(nonnull RxStateType)state action:(id <RxDisposable> (^)(RxStateType))action {
    return [self scheduleRelative:state dueTime:0.0 action:^id <RxDisposable>(id a) {
        return action(a);
    }];
}

- (nonnull id <RxDisposable>)scheduleRelative:(nonnull id)state
                                      dueTime:(RxTimeInterval)dueTime
                                       action:(id <RxDisposable>(^)(id))action {
    RxTime *time = [[self now] dateByAddingTimeInterval:dueTime];
    RxVirtualTimeUnit absoluteTime = [_converter convertToVirtualTime:time];
    RxVirtualTimeUnit adjustedTime = [self adjustScheduledTime:absoluteTime];
    return [self scheduleAbsoluteVirtual:state time:adjustedTime action:action];
}

- (nonnull id <RxDisposable>)scheduleRelativeVirtual:(nonnull id)state
                                             dueTime:(RxVirtualTimeIntervalUnit)dueTime
                                              action:(id <RxDisposable>(^)(id))action {
    RxVirtualTimeUnit time = [_converter offsetVirtualTime:self.clock offset:dueTime];
    return [self scheduleAbsoluteVirtual:state time:time action:action];
}

- (nonnull id <RxDisposable>)scheduleAbsoluteVirtual:(id)state
                                                time:(RxVirtualTimeUnit)time
                                              action:(id <RxDisposable>(^)(id))action {
   
    [RxMainScheduler ensureExecutingOnScheduler];
    
    RxCompositeDisposable *compositeDisposable = [[RxCompositeDisposable alloc] init];
    
    RxVirtualSchedulerItem *item = [[RxVirtualSchedulerItem alloc] initWithAction:^id <RxDisposable> {return action(state);} 
                                                                             time:time 
                                                                               id:_nextId];
    
    _nextId++;

    [_schedulerQueue enqueue:item];

    [compositeDisposable addDisposable:item];
    return compositeDisposable;
}

- (nonnull RxVirtualTimeUnit)adjustScheduledTime:(nonnull RxVirtualTimeUnit)time {
    return time;
}

- (void)start {
    [RxMainScheduler ensureExecutingOnScheduler];
    
    if (_running) {
        return;
    }
    
    _running = YES;
    do {
        RxVirtualSchedulerItem *next = [self findNext];
        if (!next) {
            break;
        }
        
        if ([_converter compareVirtualTime:next.time with:self.clock].greaterThan) {
            _clock = next.time;
        }

        [next invoke];
        [_schedulerQueue remove:next];
        
    } while (_running);
    
    _running = NO;
}

- (nullable RxVirtualSchedulerItem *)findNext {
    RxVirtualSchedulerItem *front = [_schedulerQueue peek];
    while (front) {
        if (front.disposed) {
            [_schedulerQueue remove:front];
            front = [_schedulerQueue peek];
            continue;
        }
        return front;
    }
    return nil;
}

- (void)advanceTo:(nonnull RxVirtualTimeUnit)virtualTime {
    [RxMainScheduler ensureExecutingOnScheduler];

    if (_running) {
        rx_fatalError(@"Scheduler is already running");
        return;
    }
    
    _running = YES;
    
    do {
        RxVirtualSchedulerItem *next = [self findNext];
        if (!next) {
            break;
        }
        
        if ([_converter compareVirtualTime:next.time with:virtualTime].greaterThan) {
            break;
        }
        
        if ([_converter compareVirtualTime:next.time with:self.clock].greaterThan) {
            _clock = next.time;
        }

        [next invoke];
        [_schedulerQueue remove:next];
    } while (_running);
    
    _clock = virtualTime;
    _running = NO;
}

- (void)sleep:(nonnull RxVirtualTimeIntervalUnit)virtualInterval {
    [RxMainScheduler ensureExecutingOnScheduler];

    RxVirtualTimeUnit sleepTo = [_converter offsetVirtualTime:self.clock offset:virtualInterval];
    if ([_converter compareVirtualTime:sleepTo with:self.clock].lessThan) {
        rx_fatalError(@"Can't sleep to past.");
        return;
    }
    _clock = sleepTo;
}

- (void)stop {
    [RxMainScheduler ensureExecutingOnScheduler];

    _running = NO;
}

#if TRACE_RESOURCES
- (void)dealloc {
    OSAtomicDecrement32(&rx_resourceCount);
}
#endif

@end