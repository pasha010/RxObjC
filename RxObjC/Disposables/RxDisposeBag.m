//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxDisposeBag.h"
#import "RxDisposable.h"


@implementation RxDisposeBag {
    NSRecursiveLock *__nonnull _lock;
    NSMutableArray<id <RxDisposable>> *__nonnull _disposables;
    BOOL _disposed;
}

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _lock = [[NSRecursiveLock alloc] init];
        _disposables = [NSMutableArray array];
        _disposed = NO;
    }
    return self;
}

- (void)addDisposable:(nonnull id <RxDisposable>)disposable {
    [[self _addDisposable:disposable] dispose];
}

- (nullable id <RxDisposable>)_addDisposable:(nonnull id <RxDisposable>)disposable {
    [_lock lock];

    id <RxDisposable> d = disposable;
    
    if (!_disposed) {
        [_disposables addObject:disposable];
        d = nil;
    }
    
    [_lock unlock];
    return d;
}

/**
This is internal on purpose, take a look at `CompositeDisposable` instead.
*/
- (void)dispose {
    NSArray<id <RxDisposable>> *oldDisposables = [self _dispose];
    for (id <RxDisposable> disposable in oldDisposables) {
        [disposable dispose];
    }
}

- (nonnull NSArray<id <RxDisposable>> *)_dispose {
    [_lock lock];

    NSArray<id <RxDisposable>> *disposables = [_disposables copy];

    [_disposables removeAllObjects];
    _disposed = YES;
    
    [_lock unlock];
    
    return disposables;
}

- (void)dealloc {
    [self dispose];
}

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma GCC diagnostic ignored "-Wprotocol"

@implementation NSObject (RxAddDisposableTo)

- (void)addDisposableTo:(nonnull RxDisposeBag *)bag {
    [bag addDisposable:self];
}

@end

#pragma clang diagnostic pop