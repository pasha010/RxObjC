//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxBinaryDisposable.h"


@implementation RxBinaryDisposable {
    int32_t _disposed;
    /// state
    id <RxDisposable> _disposable1;
    id <RxDisposable> _disposable2;
}

- (nonnull instancetype)initWithFirstDisposable:(nullable id <RxDisposable>)disposable1 andSecondDisposable:(nullable id <RxDisposable>)disposable2 {
    self = [super init];
    if (self) {
        _disposed = 0;
        _disposable1 = disposable1;
        _disposable2 = disposable2;
    }
    return self;
}

- (BOOL)disposed {
    return _disposed > 0;
}

/**
Calls the disposal action if and only if the current instance hasn't been disposed yet.

After invoking disposal action, disposal action will be dereferenced.
*/
- (void)dispose {
    if (OSAtomicCompareAndSwap32(0, 1, &_disposed)) {
        [_disposable1 dispose];
        [_disposable2 dispose];
        _disposable1 = nil;
        _disposable2 = nil;
    }
}


@end