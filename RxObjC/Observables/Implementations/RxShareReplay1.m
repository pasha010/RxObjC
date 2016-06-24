//
//  RxShareReplay1
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxShareReplay1.h"
#import "RxSingleAssignmentDisposable.h"
#import "RxBag.h"
#import "RxAnyObserver.h"
#import "RxLock.h"
#import "RxSynchronizedSubscribeType.h"
#import "RxNopDisposable.h"
#import "RxSubscriptionDisposable.h"


@implementation RxShareReplay1 {
    RxObservable *__nonnull _source;
    NSRecursiveLock *__nonnull _lock;
    RxSingleAssignmentDisposable *__nullable _connection;
    id __nullable _element;
    BOOL _stopped;
    RxEvent *__nullable _stopEvent;
    RxBag<RxAnyObserver *> *__nonnull _observers;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)observable {
    self = [super init];
    if (self) {
        _lock = [[NSRecursiveLock alloc] init];
        _stopped = NO;
        _observers = [[RxBag alloc] init];
        _source = observable;
    }
    return self;
}

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    return [_lock calculateLocked:^id <RxDisposable> {
        return [self _synchronized_subscribe:observer];
    }];
}

- (nonnull id <RxDisposable>)_synchronized_subscribe:(nonnull id <RxObserverType>)observer {
    if (_element) {
        [observer on:[RxEvent next:_element]];
    }
    
    if (_stopEvent) {
        [observer on:_stopEvent];
        return [RxNopDisposable sharedInstance];
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
    /// if already unsubscribed, just return
    if ([_observers removeKey:disposeKey] == nil) {
        return;
    }

    if (_observers.count == 0) {
        [_connection dispose];
        _connection = nil;
    }
}

- (void)on:(nonnull RxEvent *)event {
    [_lock performLock:^{
        [self _synchronized_on:event];
    }];
}

- (void)_synchronized_on:(nonnull RxEvent *)event {
    if (_stopped) {
        return;
    }

    if (event.type == RxEventTypeNext) {
        _element = _element;
    } else {
        _stopEvent = event;
        _stopped = YES;
        [_connection dispose];
        _connection = nil;
    }
    [_observers on:event];
}

@end