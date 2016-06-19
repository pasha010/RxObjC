//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSingleAssignmentDisposable.h"
#import "RxLock.h"
#import "RxNopDisposable.h"


@implementation RxSingleAssignmentDisposable {
    RxSpinLock *__nonnull _lock;
    BOOL _disposed;
    BOOL _disposableSet;
    id <RxDisposable> __nullable _disposable;
}

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _lock = [[RxSpinLock alloc] init];
        _disposed = NO;
        _disposableSet = NO;
    }
    return self;
}

- (nonnull id <RxDisposable>)disposable {
    return [_lock calculateLocked:^id <RxDisposable> {
        return _disposable ?: [RxNopDisposable sharedInstance];
    }];
}

- (void)setDisposable:(nonnull id <RxDisposable>)disposable {
    [[self _setDisposable:disposable] dispose];
}

- (nullable id <RxDisposable>)_setDisposable:(nonnull id <RxDisposable>)newValue {
    return [_lock calculateLocked:^id <RxDisposable> {
        if (_disposableSet) {
            rx_fatalError(@"oldState.disposable != nil");
            return nil;
        }
        
        _disposableSet = YES;
        
        if (_disposed) {
            return newValue;
        }
        
        _disposable = newValue;
        
        return nil;
    }];
};


- (BOOL)disposed {
    return _disposed;
}

/**
Disposes the underlying disposable.
*/
- (void)dispose {
    if (_disposed) {
        return;
    }
    [[self _dispose] dispose];
}

- (nullable id <RxDisposable>)_dispose {
    return [_lock calculateLocked:^id <RxDisposable> {
        _disposed = YES;
        id <RxDisposable> disposable = _disposable;
        _disposable = nil;

        return disposable;
    }];
}

@end