//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxPublishSubject.h"
#import "RxLock.h"
#import "RxBag.h"
#import "RxAnyObserver.h"
#import "RxNopDisposable.h"
#import "RxError.h"
#import "RxSubscriptionDisposable.h"


@implementation RxPublishSubject {
    RxSpinLock *__nonnull _lock;
    BOOL _disposed;
    RxBag<RxAnyObserver<id> *> *_observers;
    BOOL _stopped;
    RxEvent<id> *__nullable _stoppedEvent;
}

+ (nonnull instancetype)create {
    return [[self alloc] init];
}

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _lock = [[RxSpinLock alloc] init];
        _disposed = NO;
        _observers = [[RxBag alloc] init];
        _stopped = NO;
        _stoppedEvent = nil;
    }
    return self;
}

- (BOOL)hasObservers {
    return [[_lock calculateLocked:^NSNumber * {
        return @(_observers.count > 0);
    }] boolValue];
}

- (BOOL)disposed {
    return _disposed;
}

- (void)on:(nonnull RxEvent<id> *)event {
    [_lock performLock:^{
        [self _synchronized_on:event];
    }];
}

- (void)_synchronized_on:(nonnull RxEvent<id> *)event {
    if (event.type == RxEventTypeNext) {
        if (_disposed || _stopped) {
            return;
        }
        [_observers on:event];
    } else {
        if (!_stoppedEvent) {
            _stoppedEvent = event;
            _stopped = YES;
            [_observers on:event];
            [_observers removeAll];
        }
    }
}

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    return [_lock calculateLocked:^id <RxDisposable> {
        return [self _synchronized_subscribe:observer];
    }];
}

- (nonnull id <RxDisposable>)_synchronized_subscribe:(nonnull id <RxObserverType>)observer {
    if (_stoppedEvent) {
        [observer on:_stoppedEvent];
        return [RxNopDisposable sharedInstance];
    }
    
    if (_disposed) {
        [observer on:[RxEvent error:[RxError disposedObject:self]]];
        return [RxNopDisposable sharedInstance];
    }

    RxBagKey *key = [_observers insert:rx_asObserver(observer)];

    return [[RxSubscriptionDisposable alloc] initWithOwner:self andKey:key];
}

- (void)synchronizedUnsubscribe:(nonnull RxBagKey *)disposeKey {
    [_lock performLock:^{
        [self _synchronized_unsubscribe:disposeKey];
    }];
}

- (void)_synchronized_unsubscribe:(RxBagKey *)disposeKey {
    [_observers removeKey:disposeKey];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"

- (nonnull instancetype)asObserver {
    return self;
}

#pragma clang diagnostic pop

- (void)dispose {
    [_lock performLock:^{
        [self _synchronized_dispose];
    }];
}

- (void)_synchronized_dispose {
    _disposed = YES;
    [_observers removeAll];
    _stoppedEvent = nil;
}

@end