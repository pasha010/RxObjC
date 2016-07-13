//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxAnonymousDisposable.h"


@implementation RxAnonymousDisposable {
    RxDisposeAction __nullable _disposeAction;
    int32_t _disposed;
}

+ (nonnull instancetype)create:(nullable RxDisposeAction)disposeAction {
    return [[self alloc] initWithDisposeAction:disposeAction];
}

- (nonnull instancetype)initWithDisposeAction:(nullable RxDisposeAction)disposeAction {
    self = [super init];
    if (self) {
        _disposed = 0;
        _disposeAction = disposeAction;
    }
    return self;
}

- (BOOL)disposed {
    return _disposed == 1;
}

/**
Calls the disposal action if and only if the current instance hasn't been disposed yet.

After invoking disposal action, disposal action will be dereferenced.
*/
- (void)dispose {
    if (OSAtomicCompareAndSwap32(0, 1, &_disposed)) {
        NSAssert(_disposed == 1, @"_disposed should be equal to 1");

        if (_disposeAction) {
            _disposeAction();
            _disposeAction = nil;
        }
    }
}


@end