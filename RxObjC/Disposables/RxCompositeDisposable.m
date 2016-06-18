//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxCompositeDisposable.h"
#import "RxBag.h"


@implementation RxCompositeDisposable {
    NSLock *__nonnull _lock;
    RxBag<id <RxDisposable>> *__nullable _disposables;
}

- (nonnull instancetype)init {
    return [self initWithDisposableArray:@[]];
}

- (nonnull instancetype)initWithDisposable1:(nonnull id <RxDisposable>)disposable1
                                disposable2:(nonnull id <RxDisposable>)disposable2 {
    return [self initWithDisposableArray:@[disposable1, disposable2]];
}

- (nonnull instancetype)initWithDisposable1:(nonnull id <RxDisposable>)disposable1
                                disposable2:(nonnull id <RxDisposable>)disposable2
                                disposable3:(nonnull id <RxDisposable>)disposable3 {
    return [self initWithDisposableArray:@[disposable1, disposable2, disposable3]];
}

- (nonnull instancetype)initWithDisposable1:(nonnull id <RxDisposable>)disposable1
                                disposable2:(nonnull id <RxDisposable>)disposable2
                                disposable3:(nonnull id <RxDisposable>)disposable3
                                disposable4:(nonnull id <RxDisposable>)disposable4 {
    return [self initWithDisposableArray:@[disposable1, disposable2, disposable3, disposable4]];
}

- (nonnull instancetype)initWithDisposableArray:(nonnull NSArray<id <RxDisposable>> *)disposables {
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
        _disposables = [[RxBag alloc] init];
        if (disposables) {
            for (id <RxDisposable> disposable in disposables) {
                [_disposables insert:disposable];
            }
        }
    }
    return self;
}

- (BOOL)disposed {
    [_lock lock];
    BOOL isNil = _disposables == nil;
    [_lock unlock];
    return isNil;
}

- (nullable RxBagKey *)addDisposable:(nonnull id <RxDisposable>)disposable {
    RxBagKey *key = [self _addDisposable:disposable];
    if (!key) {
        [disposable dispose];
    }
    return key;
}

- (nullable RxBagKey *)_addDisposable:(nonnull id <RxDisposable>)disposable {
    [_lock lock];
    RxBagKey *key = [_disposables insert:disposable];
    [_lock unlock];

    return key;
}


- (NSUInteger)count {
    [_lock lock];
    NSUInteger count = [_disposables count];
    [_lock unlock];
    return count;
}

- (void)removeDisposable:(nonnull RxBagKey *)key {
    [self _removeDisposable:key];
}

- (nullable id <RxDisposable>)_removeDisposable:(nonnull RxBagKey *)key {
    [_lock lock];
    id <RxDisposable> disposable = [_disposables removeKey:key];
    [_lock unlock];
    return disposable;
}

- (void)dispose {
    RxBag *bag = [self _dispose];
    if (bag) {
        rx_disposeAllInBag(bag);
    }
}

- (nullable RxBag<id <RxDisposable>> *)_dispose {
    [_lock lock];
    
    RxBag *disposeBag = _disposables;
    _disposables = nil;
    
    [_lock unlock];
    
    return disposeBag;
}


@end