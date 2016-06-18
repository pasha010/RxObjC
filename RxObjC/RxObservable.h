//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservableType.h"
#import "RxEvent.h"

NS_ASSUME_NONNULL_BEGIN

/**
A type-erased `ObservableType`.

It represents a push style sequence.
*/
@interface RxObservable<__covariant Element> : NSObject <RxObservableType>

- (nonnull instancetype)init;

/**
 Subscribes an event handler to an observable sequence.

- parameter on: Action to invoke for each event in the observable sequence.
- returns: Subscription object used to unsubscribe from the observable sequence.
*/
- (nonnull id <RxDisposable>)subscribeOn:(nonnull void(^)(RxEvent<Element> *__nonnull))on;

/**
Subscribes an element handler, an error handler, a completion handler and disposed handler to an observable sequence.

- parameter onNext: Action to invoke for each element in the observable sequence.
- parameter onError: Action to invoke upon errored termination of the observable sequence.
- parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
- parameter onDisposed: Action to invoke upon any type of termination of sequence (if the sequence has
    gracefully completed, errored, or if the generation is cancelled by disposing subscription).
- returns: Subscription object used to unsubscribe from the observable sequence.
*/
- (nonnull id<RxDisposable>)subscribeOnNext:(nullable void(^)(id __nonnull))onNext
                                    onError:(nullable void(^)(NSError *__nonnull))onError
                                onCompleted:(nullable void(^)())onCompleted
                                 onDisposed:(nullable void(^)())onDisposed;

/**
Subscribes an element handler to an observable sequence.

- parameter onNext: Action to invoke for each element in the observable sequence.
- returns: Subscription object used to unsubscribe from the observable sequence.
*/
- (nonnull id<RxDisposable>)subscribeNext:(nonnull void(^)(RxEvent<Element> *__nonnull))onNext;

/**
Subscribes an error handler to an observable sequence.

- parameter onError: Action to invoke upon errored termination of the observable sequence.
- returns: Subscription object used to unsubscribe from the observable sequence.
*/
- (nonnull id<RxDisposable>)subscribeError:(nullable void(^)(NSError *__nonnull))onError;

/**
Subscribes a completion handler to an observable sequence.

- parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
- returns: Subscription object used to unsubscribe from the observable sequence.
*/
- (nonnull id<RxDisposable>)subscribeCompleted:(nullable void(^)())onCompleted;

/**
 * All internal subscribe calls go through this method.
 */
- (nonnull id<RxDisposable>)subscribeSafe:(nonnull id<RxObserverType>)observer;

- (nonnull RxObservable *)_composeMap:(nonnull SEL)mapSelector;

@end

NS_ASSUME_NONNULL_END