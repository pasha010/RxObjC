//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxBooleanDisposable.h"


@implementation RxBooleanDisposable {
    BOOL _disposed;
}

- (instancetype)init {
    return [self initWithDisposed:NO];
}

- (instancetype)initWithDisposed:(BOOL)disposed {
    self = [super init];
    if (self) {
        _disposed = disposed;
    }
    return self;
}

- (void)dispose {
    _disposed = YES;
}

- (BOOL)disposed {
    return _disposed;
}


@end