//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservable.h"
#import "RxObservableBlockTypedef.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (RxAggregate) <RxObservableType>
/**
Applies an `accumulator` function over an observable sequence, returning the result of the aggregation as a single element in the result sequence. The specified `seed` value is used as the initial accumulator value.

For aggregation behavior with incremental intermediate results, see `scan`.

- seealso: [reduce operator on reactivex.io](http://reactivex.io/documentation/operators/reduce.html)

- parameter seed: The initial accumulator value.
- parameter accumulator: A accumulator function to be invoked on each element.
- parameter mapResult: A function to transform the final accumulator value into the result value.
- returns: An observable sequence containing a single element with the final accumulator value.
*/
- (nonnull RxObservable<id> *)reduce:(id)seed accumulator:(RxAccumulatorType)accumulator mapResult:(ResultSelectorType)mapResult;

/**
Applies an `accumulator` function over an observable sequence, returning the result of the aggregation as a single element in the result sequence. The specified `seed` value is used as the initial accumulator value.

For aggregation behavior with incremental intermediate results, see `scan`.

- seealso: [reduce operator on reactivex.io](http://reactivex.io/documentation/operators/reduce.html)

- parameter seed: The initial accumulator value.
- parameter accumulator: A accumulator function to be invoked on each element.
- returns: An observable sequence containing a single element with the final accumulator value.
*/
- (nonnull RxObservable<id> *)reduce:(id)seed accumulator:(RxAccumulatorType)accumulator;


@end

NS_ASSUME_NONNULL_END