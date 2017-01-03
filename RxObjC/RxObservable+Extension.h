//
//  RxObservable(Extension)
//  RxObjC
// 
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservable.h"

@protocol RxDisposable;
@protocol RxObserverType;
@class RxEvent<E>;

NS_ASSUME_NONNULL_BEGIN

@interface RxObservable<E> (Subscription)

/**
 Subscribes an event handler to an observable sequence.

- parameter on: Action to invoke for each event in the observable sequence.
- returns: Subscription object used to unsubscribe from the observable sequence.
*/
- (nonnull id <RxDisposable>)subscribeWith:(nonnull void(^)(RxEvent<E> *__nonnull event))on;

/**
Subscribes an element handler, an error handler, a completion handler and disposed handler to an observable sequence.

- parameter onNext: Action to invoke for each element in the observable sequence.
- parameter onError: Action to invoke upon errored termination of the observable sequence.
- parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
- parameter onDisposed: Action to invoke upon any type of termination of sequence (if the sequence has
    gracefully completed, errored, or if the generation is cancelled by disposing subscription).
- returns: Subscription object used to unsubscribe from the observable sequence.
*/
- (nonnull id<RxDisposable>)subscribeOnNext:(nullable void(^)(E __nonnull element))onNext
                                    onError:(nullable void(^)(NSError *__nonnull error))onError
                                onCompleted:(nullable void(^)())onCompleted
                                 onDisposed:(nullable void(^)())onDisposed;


- (nonnull id<RxDisposable>)subscribeOnNext:(nonnull void(^)(E __nonnull element))onNext
                                    onError:(nullable void(^)(NSError *__nonnull error))onError;

- (nonnull id<RxDisposable>)subscribeOnNext:(nonnull void(^)(E __nonnull element))onNext
                                onCompleted:(nullable void(^)())onCompleted;

- (nonnull id<RxDisposable>)subscribeOnNext:(nonnull void(^)(E __nonnull element))onNext
                                    onError:(nullable void(^)(NSError *__nonnull error))onError
                                onCompleted:(nullable void(^)())onCompleted;

/**
Subscribes an element handler to an observable sequence.

- parameter onNext: Action to invoke for each element in the observable sequence.
- returns: Subscription object used to unsubscribe from the observable sequence.
*/
- (nonnull id<RxDisposable>)subscribeNext:(nonnull void(^)(E __nonnull element))onNext;

/**
Subscribes an error handler to an observable sequence.

- parameter onError: Action to invoke upon errored termination of the observable sequence.
- returns: Subscription object used to unsubscribe from the observable sequence.
*/
- (nonnull id<RxDisposable>)subscribeError:(nullable void(^)(NSError *__nonnull error))onError;

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

@end

NS_ASSUME_NONNULL_END