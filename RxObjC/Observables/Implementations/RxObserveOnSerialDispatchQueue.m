//
//  RxObserveOnSerialDispatchQueue
//  RxObjC
// 
//  Created by Pavel Malkov on 26.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObserveOnSerialDispatchQueue.h"
#import "RxSerialDispatchQueueScheduler.h"
#import "RxObserverBase.h"
#import "RxSingleAssignmentDisposable.h"
#import "RxNopDisposable.h"
#import "RxTuple.h"

@interface RxObserveOnSerialDispatchQueueSink<O : id<RxObserverType>> : RxObserverBase {
@package
    RxSingleAssignmentDisposable *__nonnull _subscription;
@private
    RxSerialDispatchQueueScheduler *__nonnull _scheduler;
    id <RxObserverType> __nonnull _observer;
    id <RxDisposable> (^_cachedScheduleLambda)(RxTuple2<RxObserveOnSerialDispatchQueueSink *, RxEvent *> *);
}
@end

@implementation RxObserveOnSerialDispatchQueueSink

- (nonnull instancetype)initWithScheduler:(nonnull RxSerialDispatchQueueScheduler *)scheduler 
                                 observer:(nonnull id <RxObserverType>)observer {
    self = [super init];
    if (self) {
        _subscription = [[RxSingleAssignmentDisposable alloc] init];
        _scheduler = scheduler;
        _observer = observer;
        _cachedScheduleLambda = ^id <RxDisposable> __nonnull(RxTuple2<RxObserveOnSerialDispatchQueueSink *, RxEvent *> *tuple) {
            RxObserveOnSerialDispatchQueueSink *sink = tuple.first;
            RxEvent *event = tuple.second;
            [sink->_observer on:event];
            if (event.isStopEvent) {
                [sink dispose];
            }
            return [RxNopDisposable sharedInstance];
        };
    }
    return self;
}

- (void)_onCore:(nonnull RxEvent *)event {
    [_scheduler schedule:[RxTuple2 tupleWithArray:@[self, event]] action:_cachedScheduleLambda];
}

- (void)dispose {
    [super dispose];
    [_subscription dispose];
}

@end

@implementation RxObserveOnSerialDispatchQueue

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source 
                             scheduler:(nonnull RxSerialDispatchQueueScheduler *)scheduler {
    self = [super init];
    if (self) {
        _source = source;
        _scheduler = scheduler;
#if TRACE_RESOURCES
        OSAtomicIncrement32(&rx_resourceCount);
        OSAtomicIncrement32(&rx_numberOfSerialDispatchQueueObservables);
#endif
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxObserveOnSerialDispatchQueueSink *sink = [[RxObserveOnSerialDispatchQueueSink alloc] initWithScheduler:_scheduler observer:observer];
    sink->_subscription.disposable = [_source subscribe:sink];
    return sink;
}

#if TRACE_RESOURCES
- (void)dealloc {
    OSAtomicDecrement32(&rx_resourceCount);
    OSAtomicDecrement32(&rx_numberOfSerialDispatchQueueObservables);
}
#endif

@end