//
//  RxObservable(StandardSequenceOperators)
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservableType.h"
#import "RxObservableBlockTypedef.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (RxFilter) <RxObservableType>
/**
 * Filters the elements of an observable sequence based on a predicate.
 * @see [filter operator on reactivex.io](http://reactivex.io/documentation/operators/filter.html)
 * @param predicate: A function to test each source element for a condition.
 * @return: An observable sequence that contains elements from the input sequence that satisfy the condition.
 */
- (nonnull RxObservable *)filter:(nonnull BOOL(^)(id __nonnull element))predicate;

@end

@interface NSObject (RxTakeWhile) <RxObservableType>
/**
 * Returns elements from an observable sequence as long as a specified condition is true.
 * @see [takeWhile operator on reactivex.io](http://reactivex.io/documentation/operators/takewhile.html)
 * @param predicate: A function to test each element for a condition.
 * @return: An observable sequence that contains the elements from the input sequence that occur before the element at which the test no longer passes.
 */
- (nonnull RxObservable *)takeWhile:(nonnull BOOL(^)(id __nonnull element))predicate;

/**
 * Returns elements from an observable sequence as long as a specified condition is true.
 * The element's index is used in the logic of the predicate function.
 * @see [takeWhile operator on reactivex.io](http://reactivex.io/documentation/operators/takewhile.html)
 * @param predicate: A function to test each element for a condition; the second parameter of the function represents the index of the source element.
 * @return: An observable sequence that contains the elements from the input sequence that occur before the element at which the test no longer passes.
 */
- (nonnull RxObservable *)takeWhileWithIndex:(nonnull BOOL(^)(id __nonnull element, NSUInteger index))predicate;

@end

@interface NSObject (RxTakeSequence) <RxObservableType>
/**
 * Returns a specified number of contiguous elements from the start of an observable sequence.
 * @see [take operator on reactivex.io](http://reactivex.io/documentation/operators/take.html)
 * @param count: The number of elements to return.
 * @return: An observable sequence that contains the specified number of elements from the start of the input sequence.
 */
- (nonnull RxObservable *)take:(NSUInteger)count;

@end

@interface NSObject (RxTakeLast) <RxObservableType>
/**
 * Returns a specified number of contiguous elements from the end of an observable sequence.
 * This operator accumulates a buffer with a length enough to store elements count elements. Upon completion of the source sequence, this buffer is drained on the result sequence. This causes the elements to be delayed.
 * @see [takeLast operator on reactivex.io](http://reactivex.io/documentation/operators/takelast.html)
 * @param count: Number of elements to take from the end of the source sequence.
 * @return: An observable sequence containing the specified number of elements from the end of the source sequence.
 */
- (nonnull RxObservable *)takeLast:(NSUInteger)count;

@end

@interface NSObject (RxSkipSequence) <RxObservableType>
/**
 * Bypasses a specified number of elements in an observable sequence and then returns the remaining elements.
 * @see [skip operator on reactivex.io](http://reactivex.io/documentation/operators/skip.html)
 * @param count: The number of elements to skip before returning the remaining elements.
 * @return: An observable sequence that contains the elements that occur after the specified index in the input sequence.
 */
- (nonnull RxObservable *)skip:(NSUInteger)count;

@end

@interface NSObject (RxSkipWhile) <RxObservableType>
/**
 * Bypasses elements in an observable sequence as long as a specified condition is true and then returns the remaining elements.
 * @see [skipWhile operator on reactivex.io](http://reactivex.io/documentation/operators/skipwhile.html)
 * @param predicate: A function to test each element for a condition.
 * @return: An observable sequence that contains the elements from the input sequence starting at the first element in the linear series that does not pass the test specified by predicate.
 */
- (nonnull RxObservable *)skipWhile:(nonnull BOOL(^)(id __nonnull element))predicate;

/**
 * Bypasses elements in an observable sequence as long as a specified condition is true and then returns the remaining elements.
 * The element's index is used in the logic of the predicate function.
 * @see [skipWhile operator on reactivex.io](http://reactivex.io/documentation/operators/skipwhile.html)
 * @param predicate: A function to test each element for a condition; the second parameter of the function represents the index of the source element.
 * @return: An observable sequence that contains the elements from the input sequence starting at the first element in the linear series that does not pass the test specified by predicate.
 */
- (nonnull RxObservable *)skipWhileWithIndex:(nonnull BOOL(^)(id __nonnull element, NSUInteger index))predicate;

@end

@interface NSObject (RxMap) <RxObservableType>
/**
 * Projects each element of an observable sequence into a new form.
 * @see [map operator on reactivex.io](http://reactivex.io/documentation/operators/map.html)
 * @param mapSelector: A transform function to apply to each source element.
 * @return: An observable sequence whose elements are the result of invoking the transform function on each element of source.
 */
- (nonnull RxObservable *)map:(RxMapSelector)mapSelector;

/**
 * Projects each element of an observable sequence into a new form by incorporating the element's index.
 * @see [map operator on reactivex.io](http://reactivex.io/documentation/operators/map.html)
 * @param mapSelector: A transform function to apply to each source element; the second parameter of the function represents the index of the source element.
 * @return: An observable sequence whose elements are the result of invoking the transform function on each element of source.
 */
- (nonnull RxObservable *)mapWithIndex:(RxMapWithIndexSelector)mapSelector;

@end

@interface NSObject (RxFlatMap) <RxObservableType>
/**
 * Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.
 * @see [flatMap operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)
 * @param selector: A transform function to apply to each element.
 * @return: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
 */
- (nonnull RxObservable *)flatMap:(nonnull id <RxObservableConvertibleType>(^)(id __nonnull element))selector;

/**
 * Projects each element of an observable sequence to an observable sequence by incorporating the element's index and merges the resulting observable sequences into one observable sequence.
 * @see [flatMap operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)
 * @param selector: A transform function to apply to each element; the second parameter of the function represents the index of the source element.
 * @return: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
 */
- (nonnull RxObservable *)flatMapWithIndex:(nonnull id <RxObservableConvertibleType>(^)(id __nonnull element, NSUInteger index))selector;

@end

@interface NSObject (RxFlatMapFirst) <RxObservableType>
/**
 * Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.
 * If element is received while there is some projected observable sequence being merged it will simply be ignored.
 * @see [flatMapFirst operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)
 * @param selector: A transform function to apply to element that was observed while no observable is executing in parallel.
 * @return: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence that was received while no other sequence was being calculated.
 */
- (nonnull RxObservable *)flatMapFirst:(nonnull id <RxObservableConvertibleType>(^)(id __nonnull element))selector;

@end

@interface NSObject (RxFlatMapLatest) <RxObservableType>
/**
 * Projects each element of an observable sequence into a new sequence of observable sequences and then
 * transforms an observable sequence of observable sequences into an observable sequence producing values only from the most recent observable sequence.
 * It is a combination of `map` + `switchLatest` operator
 * @see [flatMapLatest operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)
 * @param selector: A transform function to apply to each element.
 * @return: An observable sequence whose elements are the result of invoking the transform function on each element of source producing an
            Observable of Observable sequences and that at any point in time produces the elements of the most recent inner observable sequence that has been received.
 */
- (nonnull RxObservable *)flatMapLatest:(nonnull id <RxObservableConvertibleType>(^)(id __nonnull element))selector;

@end

@interface NSObject (RxElementAt) <RxObservableType>
/**
 * Returns a sequence emitting only item _n_ emitted by an Observable
 * @see [elementAt operator on reactivex.io](http://reactivex.io/documentation/operators/elementat.html)
 * @param index: The index of the required item (starting from 0).
 * @return: An observable sequence that emits the desired item as its own sole emission.
 */
- (nonnull RxObservable *)elementAt:(NSUInteger)index;

@end

@interface NSObject (RxSingle) <RxObservableType>
/**
 * The single operator is similar to first, but throws a `RxError.NoElements` or `RxError.MoreThanOneElement`
 * if the source Observable does not emit exactly one item before successfully completing.
 * @see [single operator on reactivex.io](http://reactivex.io/documentation/operators/first.html)
 * @return: An observable sequence that emits a single item or throws an exception if more (or none) of them are emitted.
 */
- (nonnull RxObservable *)single;

/**
 * The single operator is similar to first, but throws a `RxError.NoElements` or `RxError.MoreThanOneElement`
 * if the source Observable does not emit exactly one item before successfully completing.
 * @see [single operator on reactivex.io](http://reactivex.io/documentation/operators/first.html)
 * @param predicate: A function to test each source element for a condition.
 * @return: An observable sequence that emits a single item or throws an exception if more (or none) of them are emitted.
 */
- (nonnull RxObservable *)single:(nonnull BOOL(^)(id __nonnull element))predicate;

@end

NS_ASSUME_NONNULL_END