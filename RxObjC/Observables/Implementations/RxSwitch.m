//
//  RxSwitch
//  RxObjC
// 
//  Created by Pavel Malkov on 03.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSwitch.h"
#import "RxSink.h"
#import "RxLockOwnerType.h"
#import "RxSynchronizedOnType.h"
#import "RxSerialDisposable.h"
#import "RxStableCompositeDisposable.h"

@interface RxSwitchSink<SourceType, S : id <RxObservableConvertibleType>, O : id <RxObserverType>> : RxSink<O> <RxObserverType, RxLockOwnerType, RxSynchronizedOnType>

@property (nonnull, readonly) RxSingleAssignmentDisposable *subscriptions;
@property (nonnull, readonly) RxSerialDisposable *innerSubscription;
@property BOOL stopped;
@property NSUInteger latest;
@property BOOL hasLatest;

- (nonnull id <RxDisposable>)run:(nonnull RxObservable *)source;

- (nonnull id <RxObservableConvertibleType>)performMap:(nonnull id)element;

@end

@interface RxSwitchIter<SourceType, S : id <RxObservableConvertibleType>, O : id <RxObserverType>> : NSObject <RxObserverType, RxLockOwnerType, RxSynchronizedOnType>
- (nonnull instancetype)initWithParent:(nonnull RxSwitchSink *)parent id:(NSUInteger)id _self:(nonnull id <RxDisposable>)__self;
@end

@implementation RxSwitchSink {
    NSRecursiveLock *__nonnull _lock;
}

- (nonnull instancetype)initWithObserver:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _subscriptions = [[RxSingleAssignmentDisposable alloc] init];
        _innerSubscription = [[RxSerialDisposable alloc] init];
        _lock = [[NSRecursiveLock alloc] init];
        _stopped = NO;
        _latest = 0;
        _hasLatest = NO;
    }
    return self;
}

- (NSRecursiveLock *)lock {
    return _lock;
}

- (nonnull id <RxDisposable>)run:(nonnull RxObservable *)source {
    id <RxDisposable> subscription = [source subscribe:self];
    _subscriptions.disposable = subscription;
    return [RxStableCompositeDisposable createDisposable1:_subscriptions disposable2:_innerSubscription];
}

- (void)on:(nonnull RxEvent *)event {
    [self synchronizedOn:event];
}

- (nonnull id <RxObservableConvertibleType>)performMap:(nonnull id)element {
    return rx_abstractMethod();
}

- (void)_synchronized_on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            rx_tryCatch(self, ^{
                RxObservable *observable = [[self performMap:event.element] asObservable];
                _hasLatest = YES;
                _latest++;
                NSUInteger latest = _latest;

                RxSingleAssignmentDisposable *d = [[RxSingleAssignmentDisposable alloc] init];
                _innerSubscription.disposable = d;
                
                id <RxObserverType> observer = [[RxSwitchIter alloc] initWithParent:self id:latest _self:d];
                id <RxDisposable> disposable = [observable subscribe:observer];
                d.disposable = disposable;
            }, ^(NSError *error) {
                [self forwardOn:[RxEvent error:error]];
                [self dispose];
            });
            break;
        }
        case RxEventTypeError: {
            [self forwardOn:[RxEvent error:event.error]];
            [self dispose];
            break;
        }
        case RxEventTypeCompleted: {
            _stopped = YES;
            [_subscriptions dispose];

            if (!_hasLatest) {
                [self forwardOn:[RxEvent completed]];
                [self dispose];
            }
            break;
        }
    }
}

@end

@implementation RxSwitchIter {
    RxSwitchSink *__nonnull _parent;
    NSUInteger _id;
    id <RxDisposable> __nonnull _self;
}

- (nonnull instancetype)initWithParent:(nonnull RxSwitchSink *)parent id:(NSUInteger)id _self:(nonnull id <RxDisposable>)__self {
    self = [super init];
    if (self) {
        _parent = parent;
        _id = id;
        _self = __self;
    }
    return self;
}

- (nonnull NSRecursiveLock *)lock {
    return [_parent lock];
}

- (void)on:(nonnull RxEvent *)event {
    [self synchronizedOn:event];
}

- (void)_synchronized_on:(nonnull RxEvent *)event {
    if (event.type != RxEventTypeNext) {
        [_self dispose];
    }

    if (_parent.latest != _id) {
        return;
    }

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
            _parent.hasLatest = NO;
            if (_parent.stopped) {
                [_parent forwardOn:event];
                [_parent dispose];
            }
            break;
        }
    }
}

@end

@interface RxSwitchIdentitySink<S : id <RxObservableConvertibleType>, O : id <RxObserverType>> : RxSwitchSink<S, S, O>
@end

@implementation RxSwitchIdentitySink

- (nonnull id <RxObservableConvertibleType>)performMap:(nonnull id <RxObservableConvertibleType>)element {
    return element;
}

@end

@interface RxMapSwitchSink<SourceType, S : id <RxObservableConvertibleType>, O : id<RxObserverType>> : RxSwitchSink<SourceType, S, O>
@end

@implementation RxMapSwitchSink {
    RxFlatMapSelector _selector;
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

@implementation RxSwitch {
    RxObservable<id <RxObservableConvertibleType>> *__nonnull _source;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id <RxObservableConvertibleType>> *)source {
    self = [super init];
    if (self) {
        _source = source;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxSwitchIdentitySink *sink = [[RxSwitchIdentitySink alloc] initWithObserver:observer];
    sink.disposable = [sink run:_source];
    return sink;
}

@end

@implementation RxFlatMapLatest {
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
    RxMapSwitchSink *sink = [[RxMapSwitchSink alloc] initWithSelector:_selector observer:observer];
    sink.disposable = [sink run:_source];
    return sink;
}

@end