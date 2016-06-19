//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSerialDisposable.h"
#import "NSRecursiveLock+RxAdditions.h"


@implementation RxSerialDisposable {
    RxSpinLock *__nonnull _lock;
    /// state
    id <RxDisposable> __nullable _current;
    BOOL _disposed;
    id <RxDisposable> __nullable _disposable;
}

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _lock = [[RxSpinLock alloc] init];
        _disposed = NO;
    }
    return self;
}

- (nullable id <RxDisposable>)disposable {
    return [_lock calculateLocked:^id <RxDisposable> {
        return _disposable;
    }];
}

- (void)setDisposable:(nullable id <RxDisposable>)newDisposable {
    id <RxDisposable> disposable = [_lock calculateLocked:^id <RxDisposable> {
        if (_disposed) {
            return newDisposable;
        } else {
            id <RxDisposable> toDispose = _current;
            _current = newDisposable;
            return toDispose;
        }
    }];
    if (disposable) {
        [disposable dispose];
    }
}


- (BOOL)disposed {
    return _disposed;
}

/**
Disposes the underlying disposable as well as all future replacements.
*/
- (void)dispose {
    id <RxDisposable> disposable = [self _dispose];
    if (disposable) {
        [disposable dispose];
    }
}

- (nullable id <RxDisposable>)_dispose {
    return [_lock calculateLocked:^id <RxDisposable> {
        if (_disposed) {
            return nil;
        } else {
            _disposed = YES;
            id <RxDisposable> current = _current;
            _current = nil;
            return current;
        }
    }];
}


@end