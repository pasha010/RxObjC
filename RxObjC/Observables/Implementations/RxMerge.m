//
//  RxMerge
//  RxObjC
// 
//  Created by Pavel Malkov on 26.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxMerge.h"
#import "RxSink.h"
#import "RxCompositeDisposable.h"
#import "RxLock.h"
#import "RxMerge+Private.h"
#import "RxSynchronizedOnType.h"
#import "RxLockOwnerType.h"
#import "RxQueue.h"

@interface RxMergeBasicSink<S: id <RxObservableConvertibleType>, O: id <RxObserverType>> : RxMergeSink<S, S, O>
@end

@implementation RxMergeBasicSink

- (nonnull id <RxObservableConvertibleType>)performMap:(nonnull id)element {
    return element;
}

@end

@implementation RxMerge {
    RxObservable *__nonnull _source;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source {
    self = [super init];
    if (self) {
        _source = source;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxMergeBasicSink *sink = [[RxMergeBasicSink alloc] initWithObserver:observer];
    sink.disposable = [sink run:_source];
    return sink;
}

@end

@interface RxMergeLimitedSink<S: id <RxObservableConvertibleType>, O: id <RxObserverType>> : RxSink<O> <RxObserverType, RxLockOwnerType, RxSynchronizedOnType>
@property (readonly) BOOL stopped;
@property (readwrite) NSUInteger activeCount;
@property (nonnull, readonly) NSRecursiveLock *lock;
@property (nonnull, readonly) RxCompositeDisposable *group;
@property (nonnull, readonly) RxQueue<S> *queue;

- (void)subscribe:(nonnull id <RxObservableConvertibleType>)innerSource group:(nonnull RxCompositeDisposable *)group;

@end

@interface RxMergeLimitedSinkIter<S: id <RxObservableConvertibleType>, O: id <RxObserverType>> : NSObject <RxObserverType, RxLockOwnerType, RxSynchronizedOnType>
@end

@implementation RxMergeLimitedSinkIter {
    RxMergeLimitedSink *__nonnull _parent;
    RxBagKey *__nonnull _key;
}

- (nonnull instancetype)initWithParent:(nonnull RxMergeLimitedSink *)parent disposeKey:(nonnull RxBagKey *)key {
    self = [super init];
    if (self) {
        _parent = parent;
        _key = key;
    }
    return self;
}

- (NSRecursiveLock *)lock {
    return _parent.lock;
}

- (void)on:(nonnull RxEvent *)event {
    [self synchronizedOn:event];
}

- (void)_synchronized_on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            [_parent forwardOn:event];
            break;
        }
        case RxEventTypeError: {
            [_parent forwardOn:event];
            [_parent dispose];
            break;
        }
        case RxEventTypeCompleted: {
            [_parent.group removeDisposable:_key];
            id <RxObservableConvertibleType> next = [_parent.queue dequeue];
            if (next) {
                [_parent subscribe:next group:_parent.group];
            } else {
                _parent.activeCount--;
                if (_parent.stopped && _parent.activeCount == 0) {
                    [_parent forwardOn:[RxEvent completed]];
                    [_parent dispose];
                }
            }
            break;
        }
    }
}

@end

@implementation RxMergeLimitedSink {
    NSUInteger _maxConcurrent;
    RxSingleAssignmentDisposable *__nonnull _sourceSubscription;
}

- (nonnull instancetype)initWithMaxConcurrent:(NSUInteger)maxConcurrent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _lock = [[NSRecursiveLock alloc] init];
        _stopped = NO;
        _activeCount = 0;
        _queue = [[RxQueue alloc] initWithCapacity:2];
        _sourceSubscription = [[RxSingleAssignmentDisposable alloc] init];
        _group = [[RxCompositeDisposable alloc] init];

        [_group addDisposable:_sourceSubscription];
        _maxConcurrent = maxConcurrent;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull RxObservable<id <RxObserverType>> *)source {
    [_group addDisposable:_sourceSubscription];
    id <RxDisposable> disposable = [source subscribe:self];
    _sourceSubscription.disposable = disposable;
    return _group;
}

- (void)subscribe:(nonnull id <RxObservableConvertibleType>)innerSource group:(nonnull RxCompositeDisposable *)group {
    RxSingleAssignmentDisposable *subscription = [[RxSingleAssignmentDisposable alloc] init];

    RxBagKey *key = [group addDisposable:subscription];
    
    if (key) {
        id <RxObserverType> observer = [[RxMergeLimitedSinkIter alloc] initWithParent:self disposeKey:key];
        id <RxDisposable> disposable = [[innerSource asObservable] subscribe:observer];
        subscription.disposable = disposable;
    }
}

- (void)on:(nonnull RxEvent *)event {
    [self synchronizedOn:event];
}

- (void)_synchronized_on:(nonnull RxEvent<id <RxObservableConvertibleType>> *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            BOOL subscribe = NO;
            if (_activeCount < _maxConcurrent) {
                _activeCount++;
                subscribe = YES;
            } else {
                [_queue enqueue:event.element];
                subscribe = NO;
            }

            if (subscribe) {
                [self subscribe:event.element group:_group];
            }
            break;
        }
        case RxEventTypeError: {
            [self forwardOn:[RxEvent error:event.error]];
            [self dispose];
            break;
        }
        case RxEventTypeCompleted: {
            if (_activeCount == 0) {
                [self forwardOn:[RxEvent completed]];
                [self dispose];
            } else {
                [_sourceSubscription dispose];
            }

            _stopped = YES;
            break;
        }
    }
}

@end

@implementation RxMergeLimited {
    RxObservable *__nonnull _source;
    NSUInteger _maxConcurrent;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source maxConcurrent:(NSUInteger)maxConcurrent {
    self = [super init];
    if (self) {
        _source = source;
        _maxConcurrent = maxConcurrent;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxMergeLimitedSink *sink = [[RxMergeLimitedSink alloc] initWithMaxConcurrent:_maxConcurrent observer:observer];
    sink.disposable = [sink run:_source];
    return sink;
}

@end

@interface RxFlatMapSink<SourceType, S : id <RxObservableConvertibleType>, O : id<RxObserverType>> : RxMergeSink<SourceType, S, O>
@end

@implementation RxFlatMapSink {
    RxFlatMapSelector __nonnull _selector;
}

- (nonnull instancetype)initWithSelector:(RxFlatMapSelector)selector observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _selector = selector;
    }
    return self;
}

- (nonnull id <RxObservableConvertibleType>)performMap:(nonnull id)element {
    return _selector(element);
}

@end

@implementation RxFlatMap {
    RxObservable *__nonnull _source;
    RxFlatMapSelector __nonnull _selector;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source selector:(RxFlatMapSelector)aSelector {
    self = [super init];
    if (self) {
        _source = source;
        _selector = aSelector;
    }

    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxFlatMapSink *sink = [[RxFlatMapSink alloc] initWithSelector:_selector observer:observer];
    sink.disposable = [sink run:_source];
    return sink;
}

@end

@interface RxFlatMapWithIndexSink<SourceType, S : id <RxObservableConvertibleType>, O : id<RxObserverType>> : RxMergeSink<SourceType, S, O>
@end

@implementation RxFlatMapWithIndexSink {
    RxFlatMapWithIndexSelector __nonnull _selector;
    NSUInteger _index;
}

- (nonnull instancetype)initWithSelector:(RxFlatMapWithIndexSelector)selector observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _index = 0;
        _selector = selector;
    }
    return self;
}

- (nonnull id <RxObservableConvertibleType>)performMap:(nonnull id)element {
    return _selector(element, rx_incrementCheckedUnsigned(&_index));
}

@end

@implementation RxFlatMapWithIndex {
    RxObservable *__nonnull _source;
    RxFlatMapWithIndexSelector __nonnull _selector;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source selector:(RxFlatMapWithIndexSelector)aSelector {
    self = [super init];
    if (self) {
        _source = source;
        _selector = aSelector;
    }

    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxFlatMapWithIndexSink *sink = [[RxFlatMapWithIndexSink alloc] initWithSelector:_selector observer:observer];
    sink.disposable = [sink run:_source];
    return sink;
}

@end

@interface RxFlatMapFirstSink<SourceType, S : id <RxObservableConvertibleType>, O : id<RxObserverType>> : RxMergeSink<SourceType, S, O>
@end

@implementation RxFlatMapFirstSink {
    RxFlatMapSelector __nonnull _selector;
}

- (nonnull instancetype)initWithSelector:(RxFlatMapSelector)selector observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _selector = selector;
    }
    return self;
}

- (BOOL)subscribeNext {
    return self.group.count == RxMergeNoIterators;
}

- (nonnull id <RxObservableConvertibleType>)performMap:(nonnull id)element {
    return _selector(element);
}

@end

@implementation RxFlatMapFirst {
    RxObservable *__nonnull _source;
    RxFlatMapSelector __nonnull _selector;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source selector:(RxFlatMapSelector)aSelector {
    self = [super init];
    if (self) {
        _source = source;
        _selector = aSelector;
    }

    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxFlatMapFirstSink *sink = [[RxFlatMapFirstSink alloc] initWithSelector:_selector observer:observer];
    sink.disposable = [sink run:_source];
    return sink;
}

@end