//
//  RxWithLatestFrom
//  RxObjC
// 
//  Created by Pavel Malkov on 28.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxWithLatestFrom.h"
#import "RxSink.h"
#import "RxSynchronizedOnType.h"
#import "RxLockOwnerType.h"
#import "RxStableCompositeDisposable.h"

@interface RxWithLatestFromSink<FirstType, SecondType, O : id<RxObserverType>> : RxSink<O> <RxObserverType, RxLockOwnerType, RxSynchronizedOnType>

@property (nonnull, readonly) NSRecursiveLock *lock;
@property (nullable) SecondType latest;

@end

@interface RxWithLatestFromSecond<FirstType, SecondType, O : id<RxObserverType>> : RxSink<O> <RxObserverType, RxLockOwnerType, RxSynchronizedOnType>
@end

@implementation RxWithLatestFromSecond {
    RxWithLatestFromSink *__nonnull _parent;
    id <RxDisposable> __nonnull _disposable;
}
- (nonnull instancetype)initWithParent:(nonnull RxWithLatestFromSink *)parent disposable:(nonnull id <RxDisposable>)disposable {
    self = [super init];
    if (self) {
        _parent = parent;
        _disposable = disposable;
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
            _parent.latest = event.element;
            break;
        }
        case RxEventTypeError: {
            [_parent forwardOn:[RxEvent error:event.error]];
            [_parent dispose];
            break;
        }
        case RxEventTypeCompleted: {
            [_disposable dispose];
            break;
        }
    }
}

@end

@implementation RxWithLatestFromSink {
    RxWithLatestFrom *__nonnull _parent;
}

- (nonnull instancetype)initWithParent:(nonnull RxWithLatestFrom *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _lock = [[NSRecursiveLock alloc] init];
        _parent = parent;
    }
    return self;
}

- (nonnull id <RxDisposable>)run {
    RxSingleAssignmentDisposable *sndSubscription = [[RxSingleAssignmentDisposable alloc] init];
    RxWithLatestFromSecond *sndO = [[RxWithLatestFromSecond alloc] initWithParent:self disposable:sndSubscription];
    
    sndSubscription.disposable = [_parent->_second subscribe:sndO];
    id <RxDisposable> fstSubscription = [_parent->_first subscribe:self];
    
    return [RxStableCompositeDisposable createDisposable1:fstSubscription disposable2:sndSubscription];
}

- (void)on:(nonnull RxEvent *)event {
    [self synchronizedOn:event];
}

- (void)_synchronized_on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            if (!_latest) {
                return;
            }

            rx_tryCatch(self, ^{
                id res = _parent->_resultSelector(event.element, _latest);

                [self forwardOn:[RxEvent next:res]];
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
            [self forwardOn:[RxEvent completed]];
            [self dispose];
            break;
        }
    }
}

@end

@implementation RxWithLatestFrom

- (nonnull instancetype)initWithFirst:(nonnull RxObservable *)first
                               second:(nonnull RxObservable *)second
                       resultSelector:(RxWithLatestFromResultSelector)resultSelector {
    self = [super init];
    if (self) {
        _first = first;
        _second = second;
        _resultSelector = resultSelector;
    }

    return self;
}


- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxWithLatestFromSink *sink = [[RxWithLatestFromSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end