//
//  RxObservable(Extension)
//  RxObjC
// 
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservableType.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (RxObservableTypeExtension) <RxObservableType>

/**
 Subscribes an event handler to an observable sequence.

- parameter on: Action to invoke for each event in the observable sequence.
- returns: Subscription object used to unsubscribe from the observable sequence.
*/
- (nonnull id <RxDisposable>)subscribeWith:(nonnull void(^)(RxEvent<id> *__nonnull))on;

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


- (nonnull id<RxDisposable>)subscribeOnNext:(nonnull void(^)(id __nonnull))onNext
                                    onError:(nullable void(^)(NSError *__nonnull))onError;

- (nonnull id<RxDisposable>)subscribeOnNext:(nonnull void(^)(id __nonnull))onNext
                                onCompleted:(nullable void(^)())onCompleted;

- (nonnull id<RxDisposable>)subscribeOnNext:(nonnull void(^)(id __nonnull))onNext
                                    onError:(nullable void(^)(NSError *__nonnull))onError
                                onCompleted:(nullable void(^)())onCompleted;

/**
Subscribes an element handler to an observable sequence.

- parameter onNext: Action to invoke for each element in the observable sequence.
- returns: Subscription object used to unsubscribe from the observable sequence.
*/
- (nonnull id<RxDisposable>)subscribeNext:(nonnull void(^)(id __nonnull))onNext;

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

@end

NS_ASSUME_NONNULL_END