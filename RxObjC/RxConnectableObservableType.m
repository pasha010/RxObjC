//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxConnectableObservableType.h"
#import "RxObjCCommon.h"
#import "RxSubjectType.h"
#import "RxLock.h"

@interface RxConnection<__covariant S : id <RxSubjectType>, E> : NSObject <RxDisposable>

- (nonnull instancetype)initWithParent:(nonnull RxConnectableObservableAdapter<S, E> *)parent
                                  lock:(RxSpinLock *)lock
                          subscription:(nonnull id <RxDisposable>)subscription;

- (void)dispose;

@end

@interface RxConnectableObservableAdapter<__covariant S : id <RxSubjectType>, E> (Private)
@property (nullable, strong) RxConnection<S, E> *connection;
@end

@implementation RxConnection {
    RxSpinLock *__nonnull _lock;
    RxConnectableObservableAdapter<id <RxSubjectType>, id> *__nullable _parent;
    id <RxDisposable> __nullable _subscription;
}

- (nonnull instancetype)initWithParent:(nonnull RxConnectableObservableAdapter<id <RxSubjectType>, id> *)parent
                                  lock:(RxSpinLock *)lock
                          subscription:(nonnull id <RxDisposable>)subscription {
    self = [super init];
    if (self) {
        _parent = parent;
        _lock = lock;
        _subscription = subscription;
    }
    return self;
}

- (void)dispose {
    [_lock performLock:^{
        if (!_parent) {
            return;
        }
        id <RxDisposable> oldSubscription = _subscription;
        if (!oldSubscription) {
            return;
        }

        _subscription = nil;
        if (_parent.connection == self) {
            _parent.connection = nil;
        }
        _parent = nil;
        [oldSubscription dispose];
    }];
}

@end

@implementation RxConnectableObservable

- (nonnull id <RxDisposable>)connect {
    return rx_abstractMethod();
}

- (RxConnectableObservable *)asConnectableObservable {
    return self;
}

@end

@implementation RxConnectableObservableAdapter {
@private
    id <RxSubjectType> __nonnull _subject;
    RxObservable<id> *__nonnull _source;
    RxSpinLock *__nonnull _lock;
    RxConnection<id <RxSubjectType>, id> *__nullable _connection;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source andSubject:(nonnull id <RxSubjectType>)subject {
    self = [super init];
    if (self) {
        _lock = [[RxSpinLock alloc] init];
        _source = source;
        _subject = subject;
        _connection = nil;
    }
    return self;
}

- (nonnull id <RxDisposable>)connect {
    return [_lock calculateLocked:^id <RxDisposable> {
        if (_connection) {
            return _connection;
        }
        id <RxDisposable> disposable = [_source subscribe:[_subject asObserver]];
        _connection = [[RxConnection alloc] initWithParent:self lock:_lock subscription:disposable];
        return _connection;
    }];
}

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    return [_subject subscribe:observer];
}

- (nullable RxConnection<id <RxSubjectType>, id> *)connection {
    return _connection;
}

- (void)setConnection:(nullable RxConnection<id <RxSubjectType>, id> *)connection {
    _connection = connection;
}

@end