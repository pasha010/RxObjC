//
//  RxBehaviorSubject
//  RxObjC
// 
//  Created by Pavel Malkov on 09.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSubjectType.h"
#import "RxBehaviorSubject.h"
#import "RxError.h"
#import "RxBag.h"
#import "RxAnyObserver.h"
#import "RxLock.h"
#import "RxNopDisposable.h"
#import "RxSubscriptionDisposable.h"


@implementation RxBehaviorSubject {
    id __nonnull _value;
    NSRecursiveLock *__nonnull _lock;
    RxEvent *__nullable _stoppedEvent;
    RxBag<RxAnyObserver *> *_observers;
}

+ (nonnull instancetype)create:(nonnull id)value {
    return [[self alloc] initWithValue:value];
}

- (nonnull instancetype)initWithValue:(nonnull id)value {
    self = [super init];
    if (self) {
        _lock = [[NSRecursiveLock alloc] init];
        _disposed = NO;
        _stoppedEvent = nil;
        _observers = [[RxBag alloc] init];
        _value = value;
    }
    return self;
}

- (nonnull id)value {
    [_lock lock];

    if (_disposed) {
        [_lock unlock];
        @throw [RxError disposedObject:self];
    }
    
    if (_stoppedEvent.error) {
        [_lock unlock];
        @throw _stoppedEvent.error;
    } else {
        id value = _value;
        [_lock unlock];
        return value;
    }
}

- (BOOL)hasObservers {
    [_lock lock];
    BOOL hasObservers = _observers.count > 0;
    [_lock unlock];
    return hasObservers;
}

- (void)on:(nonnull RxEvent<id> *)event {
    [_lock lock];
    [self _synchronized_on:event];
    [_lock unlock];
}

- (void)_synchronized_on:(nonnull RxEvent<id> *)event {
    if (_stoppedEvent || _disposed) {
        return;
    }
    
    if (event.type == RxEventTypeNext) {
        _value = event.element;
    } else {
        _stoppedEvent = event;
    }
    [_observers on:event];
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
    
    if (_stoppedEvent) {
        [observer on:_stoppedEvent];
        return [RxNopDisposable sharedInstance];
    }

    NSObject<RxObserverType> *o = ((NSObject <RxObserverType> *) observer);
    RxBagKey *key = [_observers insert:[o asObserver]];

    [observer on:[RxEvent next:_value]];

    return [[RxSubscriptionDisposable alloc] initWithOwner:self andKey:key];
}

- (void)synchronizedUnsubscribe:(nonnull RxBagKey *)disposeKey {
    [_lock lock];
    [self _synchronized_unsubscribe:disposeKey];
    [_lock unlock];
}

- (void)_synchronized_unsubscribe:(nonnull RxBagKey *)disposeKey {
    if (_disposed) {
        return;
    }

    [_observers removeKey:disposeKey];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"

- (nonnull instancetype)asObserver {
    return self;
}

#pragma clang diagnostic pop

- (void)dispose {
    [_lock lock];
    _disposed = YES;
    [_observers removeAll];
    _stoppedEvent = nil;
    [_lock unlock];
}

@end