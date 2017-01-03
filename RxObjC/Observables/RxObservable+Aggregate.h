//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservable.h"
#import "RxObservableBlockTypedef.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxObservable<E> (Aggregate)
/**
 * Applies an `accumulator` function over an observable sequence, returning the result of the aggregation as a single element in the result sequence. The specified `seed` value is used as the initial accumulator value.
 * For aggregation behavior with incremental intermediate results, see `scan`.
 * @see  [reduce operator on reactivex.io](http://reactivex.io/documentation/operators/reduce.html)
 * @param seed - The initial accumulator value.
 * @param accumulator - A accumulator function to be invoked on each element.
 * @param mapResult - A function to transform the final accumulator value into the result value.
 * @return - An observable sequence containing a single element with the final accumulator value.
 */
- (nonnull RxObservable<E> *)reduce:(id)seed accumulator:(RxAccumulatorType)accumulator mapResult:(ResultSelectorType)mapResult;

/**
 * Applies an `accumulator` function over an observable sequence, returning the result of the aggregation as a single element in the result sequence. The specified `seed` value is used as the initial accumulator value.
 * For aggregation behavior with incremental intermediate results, see `scan`.
 * @see - [reduce operator on reactivex.io](http://reactivex.io/documentation/operators/reduce.html)
 * @param seed - The initial accumulator value.
 * @param accumulator - A accumulator function to be invoked on each element.
 * @return - An observable sequence containing a single element with the final accumulator value.
 */
- (nonnull RxObservable<E> *)reduce:(id)seed accumulator:(RxAccumulatorType)accumulator;

/**
 * Converts an Observable into another Observable that emits the whole sequence as a single array and then terminates.
 * For aggregation behavior see `reduce`.
 * @see - [toArray operator on reactivex.io](http://reactivex.io/documentation/operators/to.html)
 * @return - An observable sequence containing all the emitted elements as array.
 */
- (nonnull RxObservable<NSArray<E> *> *)toArray;

@end

NS_ASSUME_NONNULL_END