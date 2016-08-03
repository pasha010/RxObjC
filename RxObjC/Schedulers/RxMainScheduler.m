//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxMainScheduler.h"
#import "RxObjCCommon.h"
#import "RxSingleAssignmentDisposable.h"

@implementation RxMainScheduler {
    dispatch_queue_t __nonnull _mainQueue;
    int32_t _numberEnqueued;
}

+ (nonnull instancetype)sharedInstance {
    static dispatch_once_t token;
    static RxMainScheduler *instance;
    dispatch_once(&token, ^{
        instance = [[RxMainScheduler alloc] initUniqueInstance];
    });
    return instance;
}

- (nonnull instancetype)initUniqueInstance {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    self = [super initWithSerialQueue:mainQueue];
    if (self) {
        _numberEnqueued = 0;
        _mainQueue = mainQueue;
    }
    return self;
}

+ (nonnull RxSerialDispatchQueueScheduler *)asyncInstance {
    static dispatch_once_t token;
    static RxSerialDispatchQueueScheduler *asyncInstance;
    dispatch_once(&token, ^{
        asyncInstance = [[RxSerialDispatchQueueScheduler alloc] initWithSerialQueue:dispatch_get_main_queue()];
    });
    return asyncInstance;
}

+ (void)ensureExecutingOnScheduler {
    if (![NSThread currentThread].isMainThread) {
        rx_fatalError(@"Executing on backgound thread. Please use `MainScheduler.instance.schedule` to schedule work on main thread.");
    }
}

- (nonnull id <RxDisposable>)scheduleInternal:(nonnull RxStateType)state action:(nonnull id <RxDisposable> (^)(RxStateType __nullable))action {
    int32_t currentNumberEnqueued = OSAtomicIncrement32(&_numberEnqueued);
    
    if ([NSThread currentThread].isMainThread && currentNumberEnqueued == 1) {
        id <RxDisposable> disposable = action(state);
        OSAtomicDecrement32(&_numberEnqueued);
        return disposable;
    }

    __block RxSingleAssignmentDisposable *cancel = [[RxSingleAssignmentDisposable alloc] init];

    dispatch_async(_mainQueue, ^{
        if (!cancel.disposed) {
            action(state);
        }
        OSAtomicDecrement32(&self->_numberEnqueued);
    });

    return cancel;
}


@end