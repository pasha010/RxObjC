//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxScheduledDisposable.h"
#import "RxObjC.h"
#import "RxImmediateSchedulerType.h"
#import "RxNopDisposable.h"

@interface RxScheduledDisposable ()
- (void)disposeInner;
@end

static id <RxDisposable> (^ const rx_disposeScheduledDisposable)(RxScheduledDisposable *) = ^id <RxDisposable>(RxScheduledDisposable *sd) {
    [sd disposeInner];
    return [RxNopDisposable sharedInstance];
};

@implementation RxScheduledDisposable {
    int32_t _disposed;
    /// state
    id <RxDisposable> __nonnull _disposable;
}

- (nonnull instancetype)initWithScheduler:(nonnull id <RxImmediateSchedulerType>)scheduler
                            andDisposable:(nonnull id <RxDisposable>)disposable {
    self = [super init];
    if (self) {
        _disposed = 0;
        _scheduler = scheduler;
        _disposable = disposable;
    }
    return self;
}

/**
- returns: Was resource disposed.
*/
- (BOOL)disposed {
    return _disposed == 1;
}

/**
Disposes the wrapped disposable on the provided scheduler.
*/
- (void)dispose {
    [_scheduler schedule:self action:rx_disposeScheduledDisposable];
}

- (void)disposeInner {
    if (OSAtomicCompareAndSwap32(0, 1, &_disposed)) {
        [_disposable dispose];
        _disposable = nil;
    }
}


@end