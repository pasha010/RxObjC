//
//  RxObservable(Single)
//  RxObjC
// 
//  Created by Pavel Malkov on 28.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservableType.h"
#import "RxObservable.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxObservable<E> (DistinctUntilChanged)

/**
 * Returns an observable sequence that contains only distinct contiguous elements according to equality operator.
 * @see [distinct operator on reactivex.io](http://reactivex.io/documentation/operators/distinct.html)
 * @return: An observable sequence only containing the distinct contiguous elements, based on equality operator, from the source sequence.
 */
- (nonnull RxObservable<E> *)distinctUntilChanged;

/**
 * Returns an observable sequence that contains only distinct contiguous elements according to the `keySelector`.
 *
 * @see [distinct operator on reactivex.io](http://reactivex.io/documentation/operators/distinct.html)
 * @param keySelector: A function to compute the comparison key for each element.
 * @return: An observable sequence only containing the distinct contiguous elements, based on a computed key value, from the source sequence.
 */
- (nonnull RxObservable<E> *)distinctUntilChangedWithKeySelector:(id(^)(E))keySelector;

/**
 * Returns an observable sequence that contains only distinct contiguous elements according to the `comparer`.
 * @see [distinct operator on reactivex.io](http://reactivex.io/documentation/operators/distinct.html)
 * @param comparer: Equality comparer for computed key values.
 * @return: An observable sequence only containing the distinct contiguous elements, based on `comparer`, from the source sequence.
 */
- (nonnull RxObservable<E> *)distinctUntilChangedWithComparer:(BOOL(^)(E lhs, E rhs))comparer;

/**
 * Returns an observable sequence that contains only distinct contiguous elements according to the keySelector and the comparer.
 * @see [distinct operator on reactivex.io](http://reactivex.io/documentation/operators/distinct.html)
 * @param keySelector: A function to compute the comparison key for each element.
 * @param comparer: Equality comparer for computed key values.
 * @return: An observable sequence only containing the distinct contiguous elements, based on a computed key value and the comparer, from the source sequence.
 */
- (nonnull RxObservable<E> *)distinctUntilChanged:(id(^)(E))keySelector comparer:(BOOL(^)(E lhs, E rhs))comparer;

@end

@interface RxObservable<E> (DoOn)
/**
 * Invokes an action for each event in the observable sequence, and propagates all observer messages through the result sequence.
 * @see [do operator on reactivex.io](http://reactivex.io/documentation/operators/do.html)
 * @param eventHandler: Action to invoke for each event in the observable sequence.
 * @return: The source sequence with the side-effecting behavior applied.
 */
- (nonnull RxObservable<E> *)doOn:(void(^)(RxEvent<E> *))eventHandler;

/**
 * Invokes an action for each event in the observable sequence, and propagates all observer messages through the result sequence.
 * @see [do operator on reactivex.io](http://reactivex.io/documentation/operators/do.html)
 * @param onNext: Action to invoke for each element in the observable sequence.
 * @param onError: Action to invoke upon errored termination of the observable sequence.
 * @param onCompleted: Action to invoke upon graceful termination of the observable sequence.
 * @return: The source sequence with the side-effecting behavior applied.
 */
- (nonnull RxObservable<E> *)doOn:(nullable void(^)(E value))onNext onError:(nullable void(^)(NSError *))onError onCompleted:(nullable void(^)())onCompleted;

/**
 * Invokes an action for each Next event in the observable sequence, and propagates all observer messages through the result sequence.
 * @param onNext: Action to invoke for each element in the observable sequence.
 * @return: The source sequence with the side-effecting behavior applied.
 */
- (nonnull RxObservable<E> *)doOnNext:(void(^)(E value))onNext;

/**
 * Invokes an action for the Error event in the observable sequence, and propagates all observer messages through the result sequence.
 * @param onError: Action to invoke upon errored termination of the observable sequence.
 * @return: The source sequence with the side-effecting behavior applied.
 */
- (nonnull RxObservable<E> *)doOnError:(void(^)(NSError *))onError;

/**
 * Invokes an action for the Completed event in the observable sequence, and propagates all observer messages through the result sequence.
 * @param onCompleted: Action to invoke upon graceful termination of the observable sequence.
 * @return: The source sequence with the side-effecting behavior applied.
 */
- (nonnull RxObservable<E> *)doOnCompleted:(void(^)())onCompleted;

@end

@interface RxObservable<E> (StartWith)
/**
 * Prepends a sequence of values to an observable sequence.
 * @see [startWith operator on reactivex.io](http://reactivex.io/documentation/operators/startwith.html)
 * @param elements: Elements to prepend to the specified sequence.
 * @return: The source sequence prepended with the specified values.
 */
- (nonnull RxObservable<E> *)startWithElements:(nonnull NSArray<E> *)elements;

- (nonnull RxObservable<E> *)startWith:(nonnull E)element;

@end

@interface RxObservable<E> (Retry)
/**
 * Repeats the source observable sequence until it successfully terminates.
 * **This could potentially create an infinite sequence.**
 * @see [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)
 * @return: Observable sequence to repeat until it successfully terminates.
 */
- (nonnull RxObservable<E> *)retry;

/**
 * Repeats the source observable sequence the specified number of times in case of an error or until it successfully terminates.
 *
 * If you encounter an error and want it to retry once, then you must use `retry(2)`
 * @see [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)
 * @param maxAttemptCount: Maximum number of times to repeat the sequence.
 * @return: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully.
 */
- (nonnull RxObservable<E> *)retry:(NSUInteger)maxAttemptCount;

/**
 * Repeats the source observable sequence on error when the notifier emits a next value.
 * If the source observable errors and the notifier completes, it will complete the source sequence.
 * @see [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)
 * @param notificationHandler: A handler that is passed an observable sequence of errors raised by the source observable and returns and observable that either continues, completes or errors. This behavior is then applied to the source observable.
 * @return: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully or is notified to error or complete.
 */
- (nonnull RxObservable<E> *)retryWhen:(nonnull id <RxObservableType>(^)(RxObservable<__kindof NSError *> *))notificationHandler;

- (nonnull RxObservable<E> *)retryWhen:(nonnull id <RxObservableType>(^)(RxObservable<__kindof NSError *> *))notificationHandler
                      customErrorClass:(nullable Class)errorClass;

@end

@interface RxObservable<E> (Scan)
/**
 * Applies an accumulator function over an observable sequence and returns each intermediate result. The specified seed value is used as the initial accumulator value.
 *
 * For aggregation behavior with no intermediate results, see `reduce`.
 * @see [scan operator on reactivex.io](http://reactivex.io/documentation/operators/scan.html)
 * @param seed: The initial accumulator value.
 * @param accumulator: An accumulator function to be invoked on each element.
 * @return: An observable sequence containing the accumulated values.
 */
- (nonnull RxObservable<id> *)scan:(nonnull id)seed accumulator:(nonnull id __nonnull(^)(id __nonnull accumulate, E __nonnull element))accumulator;

@end

NS_ASSUME_NONNULL_END