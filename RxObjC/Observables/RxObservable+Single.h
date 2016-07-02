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

@interface NSObject (RxDistinctUntilChanged) <RxObservableType>

/**
Returns an observable sequence that contains only distinct contiguous elements according to equality operator.

- seealso: [distinct operator on reactivex.io](http://reactivex.io/documentation/operators/distinct.html)

- returns: An observable sequence only containing the distinct contiguous elements, based on equality operator, from the source sequence.
*/
- (nonnull RxObservable *)distinctUntilChanged;

/**
Returns an observable sequence that contains only distinct contiguous elements according to the `keySelector`.

- seealso: [distinct operator on reactivex.io](http://reactivex.io/documentation/operators/distinct.html)

- parameter keySelector: A function to compute the comparison key for each element.
- returns: An observable sequence only containing the distinct contiguous elements, based on a computed key value, from the source sequence.
*/
- (nonnull RxObservable *)distinctUntilChangedWithKeySelector:(id(^)(id))keySelector;

/**
Returns an observable sequence that contains only distinct contiguous elements according to the `comparer`.

- seealso: [distinct operator on reactivex.io](http://reactivex.io/documentation/operators/distinct.html)

- parameter comparer: Equality comparer for computed key values.
- returns: An observable sequence only containing the distinct contiguous elements, based on `comparer`, from the source sequence.
*/
- (nonnull RxObservable *)distinctUntilChangedWithComparer:(BOOL(^)(id lhs, id rhs))comparer;

/**
Returns an observable sequence that contains only distinct contiguous elements according to the keySelector and the comparer.

- seealso: [distinct operator on reactivex.io](http://reactivex.io/documentation/operators/distinct.html)

- parameter keySelector: A function to compute the comparison key for each element.
- parameter comparer: Equality comparer for computed key values.
- returns: An observable sequence only containing the distinct contiguous elements, based on a computed key value and the comparer, from the source sequence.
*/
- (nonnull RxObservable *)distinctUntilChanged:(id(^)(id))keySelector comparer:(BOOL(^)(id lhs, id rhs))comparer;


@end

@interface NSObject (RxDoOn) <RxObservableType>
/**
Invokes an action for each event in the observable sequence, and propagates all observer messages through the result sequence.

- seealso: [do operator on reactivex.io](http://reactivex.io/documentation/operators/do.html)

- parameter eventHandler: Action to invoke for each event in the observable sequence.
- returns: The source sequence with the side-effecting behavior applied.
*/
- (nonnull RxObservable *)doOn:(void(^)(RxEvent *))eventHandler;

/**
Invokes an action for each event in the observable sequence, and propagates all observer messages through the result sequence.

- seealso: [do operator on reactivex.io](http://reactivex.io/documentation/operators/do.html)

- parameter onNext: Action to invoke for each element in the observable sequence.
- parameter onError: Action to invoke upon errored termination of the observable sequence.
- parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
- returns: The source sequence with the side-effecting behavior applied.
*/
- (nonnull RxObservable *)doOn:(nullable void(^)(id value))onNext onError:(nullable void(^)(NSError *))onError onCompleted:(nullable void(^)())onCompleted;

/**
 Invokes an action for each Next event in the observable sequence, and propagates all observer messages through the result sequence.

 - parameter onNext: Action to invoke for each element in the observable sequence.
 - returns: The source sequence with the side-effecting behavior applied.
 */
- (nonnull RxObservable *)doOnNext:(void(^)(id value))onNext;

/**
 Invokes an action for the Error event in the observable sequence, and propagates all observer messages through the result sequence.

 - parameter onError: Action to invoke upon errored termination of the observable sequence.
 - returns: The source sequence with the side-effecting behavior applied.
 */
- (nonnull RxObservable *)doOnError:(void(^)(NSError *))onError;

/**
 Invokes an action for the Completed event in the observable sequence, and propagates all observer messages through the result sequence.

 - parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
 - returns: The source sequence with the side-effecting behavior applied.
 */
- (nonnull RxObservable *)doOnCompleted:(void(^)())onCompleted;

@end

@interface NSObject (RxStartWith) <RxObservableType>
/**
Prepends a sequence of values to an observable sequence.

- seealso: [startWith operator on reactivex.io](http://reactivex.io/documentation/operators/startwith.html)

- parameter elements: Elements to prepend to the specified sequence.
- returns: The source sequence prepended with the specified values.
*/
- (nonnull RxObservable *)startWith:(nonnull NSArray *)elements;

@end

@interface NSObject (RxRetry) <RxObservableType>
/**
Repeats the source observable sequence until it successfully terminates.

**This could potentially create an infinite sequence.**

- seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

- returns: Observable sequence to repeat until it successfully terminates.
*/
- (nonnull RxObservable *)retry;

/**
Repeats the source observable sequence the specified number of times in case of an error or until it successfully terminates.

If you encounter an error and want it to retry once, then you must use `retry(2)`

- seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

- parameter maxAttemptCount: Maximum number of times to repeat the sequence.
- returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully.
*/
- (nonnull RxObservable *)retry:(NSUInteger)maxAttemptCount;

/**
Repeats the source observable sequence on error when the notifier emits a next value.
If the source observable errors and the notifier completes, it will complete the source sequence.

- seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

- parameter notificationHandler: A handler that is passed an observable sequence of errors raised by the source observable and returns and observable that either continues, completes or errors. This behavior is then applied to the source observable.
- returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully or is notified to error or complete.
*/
- (nonnull RxObservable *)retryWhen:(id <RxObservableType>(^)(RxObservable<NSError *> *))notificationHandler;

@end

@interface NSObject (RxScan) <RxObservableType>
/**
Applies an accumulator function over an observable sequence and returns each intermediate result. The specified seed value is used as the initial accumulator value.

For aggregation behavior with no intermediate results, see `reduce`.

- seealso: [scan operator on reactivex.io](http://reactivex.io/documentation/operators/scan.html)

- parameter seed: The initial accumulator value.
- parameter accumulator: An accumulator function to be invoked on each element.
- returns: An observable sequence containing the accumulated values.
*/
- (nonnull RxObservable *)scan:(nonnull id)seed accumulator:(id __nonnull(^)(id __nonnull, id __nonnull))accumulator;

@end

NS_ASSUME_NONNULL_END