//
//  RxObservable(Extension)
//  RxObjC
// 
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable+Extension.h"
#import "RxAnonymousObserver.h"
#import "RxAnonymousDisposable.h"
#import "RxNopDisposable.h"
#import "RxBinaryDisposable.h"
#import "RxObservable.h"


@implementation NSObject (RxObservableTypeExtension)

- (nonnull id <RxDisposable>)subscribeWith:(nonnull void (^)(RxEvent<id> *__nonnull ))on {
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


- (nonnull id <RxDisposable>)subscribeOnNext:(nonnull void (^)(id __nonnull))onNext
                                     onError:(nullable void (^)(NSError *__nonnull))onError {
    return [self subscribeOnNext:onNext onError:onError onCompleted:nil];
}

- (nonnull id<RxDisposable>)subscribeOnNext:(nonnull void(^)(id __nonnull))onNext
                                onCompleted:(nullable void(^)())onCompleted {
    return [self subscribeOnNext:onNext onError:nil onCompleted:onCompleted];
}

- (nonnull id <RxDisposable>)subscribeOnNext:(nonnull void (^)(id __nonnull))onNext
                                     onError:(nullable void (^)(NSError *__nonnull))onError
                                 onCompleted:(nullable void (^)())onCompleted {
    return [self subscribeOnNext:onNext onError:onError onCompleted:onCompleted onDisposed:nil];
}

- (id <RxDisposable>)subscribeNext:(void (^)(id __nonnull))onNext {
    RxAnonymousObserver *observer = [[RxAnonymousObserver alloc] initWithEventHandler:^(RxEvent *event) {
        if (event.type == RxEventTypeNext) {
            onNext([event element]);
        }
    }];
    return [self subscribeSafe:observer];
}

- (id <RxDisposable>)subscribeError:(void (^)(NSError *))onError {
    RxAnonymousObserver *observer = [[RxAnonymousObserver alloc] initWithEventHandler:^(RxEvent *event) {
        if (event.type == RxEventTypeError) {
            onError(event.error);
        }
    }];
    return [self subscribeSafe:observer];
}

- (id <RxDisposable>)subscribeCompleted:(void (^)())onCompleted {
    RxAnonymousObserver *observer = [[RxAnonymousObserver alloc] initWithEventHandler:^(RxEvent *event) {
        if (event.type == RxEventTypeCompleted) {
            onCompleted();
        }
    }];
    return [self subscribeSafe:observer];
}

- (id <RxDisposable>)subscribeSafe:(id <RxObserverType>)observer {
    return [[self asObservable] subscribe:observer];
}

@end