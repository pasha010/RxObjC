//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable.h"
#import "RxObjC.h"
#import "RxAnonymousObserver.h"
#import "RxAnonymousDisposable.h"
#import "RxNopDisposable.h"
#import "RxBinaryDisposable.h"

@implementation RxObservable

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
#if TRACE_RESOURCES
        OSAtomicIncrement32(&rx_resourceCount);
#endif
    }
    return self;
}

- (void)dealloc {
#if TRACE_RESOURCES
    OSAtomicDecrement32(&rx_resourceCount);
#endif
}


- (id <RxDisposable>)subscribe:(id <RxObserverType>)observer {
    rx_abstractMethod();
    return nil;
}

- (nonnull RxObservable *)asObservable {
    return self;
}

- (nonnull id <RxDisposable>)subscribeOn:(nonnull void (^)(RxEvent<id> *__nonnull ))on {
    id <RxObserverType> observer = [[RxAnonymousObserver alloc] initWithEventHandler:^(RxEvent<id> *__nonnull e) {
        on(e);
    }];
    return [self subscribeSafe:observer];
}

- (nonnull id <RxDisposable>)subscribeOnNext:(nullable void (^)(id __nonnull))onNext
                                     onError:(nullable void (^)(NSError *__nonnull))onError
                                 onCompleted:(nullable void (^)())onCompleted
                                  onDisposed:(nullable void(^)())onDisposed {
    id<RxDisposable> disposable = nil;

    if (onDisposed) {
        disposable = [[RxAnonymousDisposable alloc] initWithDisposeAction:onDisposed];
    } else {
        disposable = [RxNopDisposable sharedInstance];
    }

    id <RxObserverType> observer = [[RxAnonymousObserver alloc] initWithEventHandler:^(RxEvent<id> *__nonnull event) {
        switch (event.type) {
            case RxEventTypeNext: {
                if (onNext) {
                    onNext([event element]);
                }
                break;
            }
            case RxEventTypeError: {
                if (onError) {
                    onError([event error]);
                }
                [disposable dispose];
                break;
            }
            case RxEventTypeCompleted: {
                if (onCompleted) {
                    onCompleted();
                }
                [disposable dispose];
                break;
            }
        }
    }];

    return [[RxBinaryDisposable alloc] initWithFirstDisposable:[self subscribeSafe:observer] andSecondDisposable:disposable];
}

- (id <RxDisposable>)subscribeNext:(void (^)(RxEvent<id> *__nonnull))onNext {
    return nil;
}

- (id <RxDisposable>)subscribeError:(void (^)(NSError *))onError {
    return nil;
}

- (id <RxDisposable>)subscribeCompleted:(void (^)())onCompleted {
    return nil;
}

- (id <RxDisposable>)subscribeSafe:(id <RxObserverType>)observer {
    return nil;
}


- (nonnull RxObservable *)_composeMap:(nonnull SEL)mapSelector {
    return nil;
}


@end