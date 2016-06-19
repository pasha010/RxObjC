//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxRefCountDisposable.h"
#import "RxNopDisposable.h"
#import "RxLock.h"

@interface RxRefCountDisposable ()
- (void)rx_release;
@end

@interface RxRefCountInnerDisposable : RxDisposeBase <RxDisposable>
- (nonnull instancetype)initWithParent:(nonnull RxRefCountDisposable *)disposable;
@end

@implementation RxRefCountInnerDisposable {
    __weak RxRefCountDisposable *__nonnull _parent;
    int32_t _disposed;
}

- (nonnull instancetype)initWithParent:(nonnull __weak RxRefCountDisposable *)parent {
    self = [super init];
    if (self) {
        _parent = parent;
    }
    return self;
}

- (void)dispose {
    if (OSAtomicCompareAndSwap32(0, 1, &_disposed)) {
        [_parent rx_release];
    }
}

@end

@implementation RxRefCountDisposable {
    RxSpinLock *__nonnull _lock;
    id <RxDisposable> __nullable _disposable;
    BOOL _primaryDisposed;
    NSInteger _count;
}

- (nonnull instancetype)initWithDisposable:(nonnull id <RxDisposable>)disposable {
    self = [super init];
    if (self) {
        _lock = [[NSRecursiveLock alloc] init];
        _primaryDisposed = NO;
        _count = 0;
        _disposable = disposable;
    }
    return self;
}

- (BOOL)disposed {
    [_lock lock];
    BOOL result = _disposable == nil;
    [_lock unlock];
    return result;
}


- (nonnull id <RxDisposable>)rx_retain {
    return [_lock calculateLocked:^id <RxDisposable> {
        if (_disposable) {
            @try {
                rx_incrementChecked(&_count);
            }
            @catch (NSException *exception) {
                rx_fatalError(@"RefCountDisposable increment failed");
            }
            return [[RxRefCountInnerDisposable alloc] initWithParent:self];
        } else {
            return [RxNopDisposable sharedInstance];
        }
    }];
}

/**
 Disposes the underlying disposable only when all dependent disposables have been disposed.
 */
- (void)dispose {
    id <RxDisposable> oldDisposable = [_lock calculateLocked:^id <RxDisposable> {
        id <RxDisposable> _oldDisposable = _disposable;
        if (_oldDisposable && !_primaryDisposed) {
            _primaryDisposed = YES;
            if (_count == 0) {
                _disposable = nil;
                return _oldDisposable;
            }
        }
        return nil;
    }];

    if (oldDisposable) {
        [oldDisposable dispose];
    }
}

- (void)rx_release {
    id <RxDisposable> oldDisposable = [_lock calculateLocked:^id <RxDisposable> {
        id <RxDisposable> _oldDisposable = _disposable;
        if (_oldDisposable) {
            @try {
                rx_decrementChecked(&_count);
            }
            @catch (NSException *exception) {
                rx_fatalError(@"RefCountDisposable decrement on release failed");
            }

            if (_count < 0) {
                rx_fatalError(@"RefCountDisposable counter is lower than 0");
            }

            if (_primaryDisposed && _count == 0) {
                _disposable = nil;
                return _oldDisposable;
            }
        }
        return nil;
    }];

    if (oldDisposable) {
        [oldDisposable dispose];
    }

}

@end