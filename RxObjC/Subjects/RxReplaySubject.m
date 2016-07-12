//
//  RxReplaySubject
//  RxObjC
// 
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxReplaySubject.h"
#import "RxLock.h"
#import "RxBag.h"
#import "RxAnyObserver.h"
#import "RxObjCCommon.h"
#import "RxSynchronizedUnsubscribeType.h"
#import "RxSynchronizedOnType.h"
#import "RxSynchronizedSubscribeType.h"
#import "RxError.h"
#import "RxNopDisposable.h"
#import "RxSubscriptionDisposable.h"
#import "RxSynchronizedDisposeType.h"
#import "RxQueue.h"
#import "RxAnyObserver.h"

@interface RxReplayBufferBase<Element> : RxReplaySubject<Element> <RxSynchronizedUnsubscribeType>
- (void)trim;
- (void)addValueToBuffer:(nonnull id)value;
- (void)replayBuffer:(nonnull RxAnyObserver *)observer;

- (void)synchronizedDispose;
@end

@interface RxReplayOne<Element> : RxReplayBufferBase<Element>
@end

@interface RxReplayManyBase<Element> : RxReplayBufferBase <Element>

@property (nonnull, strong, readonly) RxQueue<Element> *queue;

- (nonnull instancetype)initWithQueueSize:(NSUInteger)queueSize;

@end

@interface RxReplayMany<Element> : RxReplayManyBase<Element>
- (nonnull instancetype)initWithBufferSize:(NSUInteger)size;
@end

@interface RxReplayAll<Element> : RxReplayManyBase<Element>
- (nonnull instancetype)init;
@end

@implementation RxReplaySubject

+ (nonnull instancetype)createWithBufferSize:(NSUInteger)bufferSize {
    if (bufferSize == 1) {
        return [[RxReplayOne alloc] init];
    }
    return [[RxReplayMany alloc] initWithBufferSize:bufferSize];
}

+ (nonnull instancetype)createUnbounded {
    return [[RxReplayAll alloc] init];
}

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _lock = [[RxSpinLock alloc] init];
        _observers = [[RxBag alloc] init];
        _disposed = NO;
    }
    return self;
}

- (BOOL)hasObservers {
    NSNumber *hasObservers = [_lock calculateLocked:^NSNumber *{
        return @(_observers.count > 0); 
    }];
    return hasObservers.boolValue;
}

- (void)unsubscribe {
    rx_abstractMethod();
}

- (void)on:(RxEvent *)event {
    rx_abstractMethod();
}

- (nonnull id <RxObserverType>)asObserver {
    return self;
}

- (void)dispose {
}

@end

@implementation RxReplayBufferBase

- (void)trim {
    rx_abstractMethod();
}

- (void)addValueToBuffer:(nonnull id)value {
    rx_abstractMethod();
}

- (void)replayBuffer:(nonnull RxAnyObserver *)observer {
    rx_abstractMethod();
}

- (void)on:(nonnull RxEvent<id> *)event {
    [_lock performLock:^{
        [self _synchronized_on:event];
    }];
}

- (void)_synchronized_on:(nonnull RxEvent *)event {
    if (_disposed) {
        return;
    }

    if (_stoppedEvent != nil) {
        return;
    }

    if (event.type == RxEventTypeNext) {
        [self addValueToBuffer:event.element];
        [self trim];
        [_observers on:event];
    } else {
        _stoppedEvent = event;
        [self trim];
        [_observers on:event];
        [_observers removeAll];
    }
}

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    return [_lock calculateLocked:^id <RxDisposable> {
        return [self _synchronized_subscribe:observer];
    }];
}

- (nonnull id <RxDisposable>)_synchronized_subscribe:(nonnull id <RxObserverType>)observer {
    if (_disposed) {
        [observer on:[RxEvent error:[RxError disposedObject:self]]];
        return [RxNopDisposable sharedInstance];
    }

    NSObject<RxObserverType> *obj = (NSObject<RxObserverType> *) observer;

    RxAnyObserver *anyObserver = [obj asObserver];

    [self replayBuffer:anyObserver];

    if (_stoppedEvent) {
        [observer on:_stoppedEvent];
        return [RxNopDisposable sharedInstance];
    } else {
        RxBagKey *key = [_observers insert:anyObserver];
        return [[RxSubscriptionDisposable alloc] initWithOwner:self andKey:key];
    }
}

- (void)synchronizedUnsubscribe:(nonnull id)disposeKey {
    [_lock performLock:^{
        [self _synchronized_unsubscribe:disposeKey];
    }];
}

- (void)_synchronized_unsubscribe:(nonnull id)disposeKey {
    if (_disposed) {
        return;
    }
    [_observers removeKey:disposeKey];
}

- (void)dispose {
    [super dispose];
    [self synchronizedDispose];
}

- (void)synchronizedDispose {
    [_lock performLock:^{
        [self _synchronized_dispose];
    }];
}

- (void)_synchronized_dispose {
    _disposed = YES;
    _stoppedEvent = nil;
    [_observers removeAll];
}

@end

@implementation RxReplayOne {
    id __nullable _value;
}

- (void)trim {
    /// nothing
}

- (void)addValueToBuffer:(nonnull id)value {
    _value = value;
}

- (void)replayBuffer:(nonnull RxAnyObserver *)observer {
    if (_value) {
        [observer on:[RxEvent next:_value]];
    }
}

- (void)_synchronized_dispose {
    [super _synchronized_dispose];
    _value = nil;
}

@end

@implementation RxReplayManyBase

- (nonnull instancetype)initWithQueueSize:(NSUInteger)queueSize {
    self = [super init];
    if (self) {
        _queue = [[RxQueue alloc] initWithCapacity:queueSize + 1];
    }
    return self;
}

- (void)addValueToBuffer:(nonnull id)value {
    [_queue enqueue:value];
}

- (void)replayBuffer:(nonnull RxAnyObserver *)observer {
    for (id item in _queue.array) {
        [observer on:[RxEvent next:item]];
    }
}

- (void)synchronizedDispose {
    [super synchronizedDispose];
    _queue = [[RxQueue alloc] initWithCapacity:0];
}

@end

@implementation RxReplayMany {
    NSUInteger _bufferSize;
}

- (nonnull instancetype)initWithBufferSize:(NSUInteger)size {
    self = [super initWithQueueSize:size];
    if (self) {
        _bufferSize = size;
    }
    return self;
}

- (void)trim {
    while (self.queue.count > _bufferSize) {
        [self.queue dequeue];
    }
}

@end

@implementation RxReplayAll
- (nonnull instancetype)init {
    self = [super initWithQueueSize:0];
    return self;
}

- (void)trim {
    /// nothing
}


@end