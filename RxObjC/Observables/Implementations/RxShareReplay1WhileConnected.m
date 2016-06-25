//
//  RxShareReplay1WhileConnected
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxShareReplay1WhileConnected.h"
#import "RxSingleAssignmentDisposable.h"
#import "RxBag.h"
#import "RxAnyObserver.h"
#import "RxLock.h"
#import "RxSynchronizedSubscribeType.h"
#import "RxSubscriptionDisposable.h"


@implementation RxShareReplay1WhileConnected {
    RxObservable *__nonnull _source;
    NSRecursiveLock *__nonnull _lock;
    RxBag<RxAnyObserver *> *__nonnull _observers;
    RxSingleAssignmentDisposable *__nullable _connection;
    id __nullable _element;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source {
    self = [super init];
    if (self) {
        _lock = [[NSRecursiveLock alloc] init];
        _observers = [[RxBag alloc] init];
        _source = source;
    }

    return self;
}

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    return [_lock calculateLocked:^id {
        return [self _synchronized_subscribe:observer];
    }];
}

- (nonnull id <RxDisposable>)_synchronized_subscribe:(nonnull id <RxObserverType>)observer {
    if (_element) {
        [observer on:[RxEvent next:_element]];
    }

    NSUInteger initialCount = _observers.count;

    RxBagKey *disposeKey = [_observers insert:[[RxAnyObserver alloc] initWithObserver:observer]];
    
    if (initialCount == 0) {
        RxSingleAssignmentDisposable *connection = [[RxSingleAssignmentDisposable alloc] init];
        _connection = connection;
        connection.disposable = [_source subscribe:self];
    }
    return [[RxSubscriptionDisposable alloc] initWithOwner:self andKey:disposeKey];
}

- (void)synchronizedUnsubscribe:(nonnull RxBagKey *)disposeKey {
    [_lock performLock:^{
        [self _synchronized_unsubscribe:disposeKey];
    }];
}

- (void)_synchronized_unsubscribe:(nonnull RxBagKey *)disposeKey {
    // if already unsubscribed, just return
    if ([_observers removeKey:disposeKey] == nil) {
        return;
    }
    
    if (_observers.count == 0) {
        [_connection dispose];
        _connection = nil;
        _element = nil;
    }
}

- (void)on:(nonnull RxEvent *)event {
    [_lock performLock:^{
        [self _synchronized_on:event];
    }];
}

- (void)_synchronized_on:(nonnull RxEvent *)event {
    if (event.type == RxEventTypeNext) {
        _element = event.element;
        [_observers on:event];
    } else {
        _element = nil;
        [_connection dispose];
        _connection = nil;
        RxBag<RxAnyObserver *> *observers = _observers;
        _observers = [[RxBag alloc] init];
        [observers on:event];
    }
}


@end