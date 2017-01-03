//
//  RxObservable(Multiple)
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservable.h"
#import "RxObservable+Extension.h"

@protocol RxObservableConvertibleType;

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<E> (RxCombineLatest) // where E is RxObservable
/**
 * Merges the specified observable sequences into one observable sequence by using the selector function whenever any of the observable sequences produces an element.
 * @see [combinelatest operator on reactivex.io](http://reactivex.io/documentation/operators/combinelatest.html)
 * @param resultSelector: Function to invoke whenever any of the sources produces an element.
 * @return: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
 */
- (nonnull RxObservable<id> *)combineLatest:(nonnull id(^)(NSArray<E> *__nonnull))resultSelector;

@end

@interface NSArray<E> (RxZip) // where E is RxObservable
/**
 * Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.
 * @see [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)
 * @param resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
 * @return: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
 */
- (nonnull RxObservable<id> *)zip:(nonnull id(^)(NSArray<E> *__nonnull))resultSelector;

@end

@interface RxObservable<E> (Switch)
/**
 * Transforms an observable sequence of observable sequences into an observable sequence
 * producing values only from the most recent observable sequence.
 *
 * Each time a new inner observable sequence is received, unsubscribe from the
 * previous inner observable sequence.
 * @see [switch operator on reactivex.io](http://reactivex.io/documentation/operators/switch.html)
 * @return: The observable sequence that at any point in time produces the elements of the most recent inner observable sequence that has been received.
 */
- (nonnull RxObservable<E> *)switchLatest;

@end

@interface RxObservable<E> (ConcatWith)
/**
 * Concatenates the second observable sequence to `self` upon successful termination of `self`.
 * @see [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)
 * @param second: Second observable sequence.
 * @return: An observable sequence that contains the elements of `self`, followed by those of the second sequence.
 */
- (nonnull RxObservable<E> *)concatWith:(nonnull id <RxObservableConvertibleType>)second;

@end

@interface NSArray<E> (RxConcat)
/**
 * Concatenates all observable sequences in the given sequence, as long as the previous observable sequence terminated successfully.
 *
 * This operator has tail recursive optimizations that will prevent stack overflow and enable generating
 * infinite observable sequences while using limited amount of memory during generation.
 *
 * Optimizations will be performed in cases equivalent to following:
 * @code
 * [1, [2, [3, .....].concat()].concat].concat()
 * @endcode
 * @see [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)
 * @return: An observable sequence that contains the elements of each given sequence, in sequential order.
 */
- (nonnull RxObservable<E> *)concat;

@end

@interface NSSet<E> (RxConcat)
- (nonnull RxObservable<E> *)concat;
@end

@interface NSEnumerator<E> (RxConcat)
- (nonnull RxObservable<E> *)concat:(NSUInteger)count;
@end

@interface RxObservable<E> (Concat)
/**
 * Concatenates all inner observable sequences, as long as the previous observable sequence terminated successfully.
 * @see [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)
 * @return: An observable sequence that contains the elements of each observed inner sequence, in sequential order.
 */
- (nonnull RxObservable<E> *)concat;

@end

@interface RxObservable<E> (Merge)
/**
 * Merges elements from all observable sequences in the given enumerable sequence into a single observable sequence.
 * @see [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)
 * @return: The observable sequence that merges the elements of the observable sequences.
 */
- (nonnull RxObservable<E> *)merge;

/**
 * Merges elements from all inner observable sequences into a single observable sequence, limiting the number of concurrent subscriptions to inner sequences.
 * @see [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)
 * @param maxConcurrent: Maximum number of inner observable sequences being subscribed to concurrently.
 * @return: The observable sequence that merges the elements of the inner sequences.
 */
- (nonnull RxObservable<E> *)mergeWithMaxConcurrent:(NSUInteger)maxConcurrent;

@end

@interface RxObservable<E> (Catch)
/**
 * Continues an observable sequence that is terminated by an error with the observable sequence produced by the handler.
 * @see [catch operator on reactivex.io](http://reactivex.io/documentation/operators/catch.html)
 * @param handler: Error handler function, producing another observable sequence.
 * @return: An observable sequence containing the source sequence's elements, followed by the elements produced by the handler's resulting observable sequence in case an error occurred.
 */
- (nonnull RxObservable<E> *)catchError:(RxObservable<E> *(^)(NSError *))handler;

/**
 * Continues an observable sequence that is terminated by an error with a single element.
 * @see [catch operator on reactivex.io](http://reactivex.io/documentation/operators/catch.html)
 * @param element: Last element in an observable sequence in case error occurs.
 * @return: An observable sequence containing the source sequence's elements, followed by the `element` in case an error occurred.
 */
- (nonnull RxObservable<E> *)catchErrorJustReturn:(nonnull E)element;

@end

@interface NSArray<E> (RxCatch)
/**
 * Continues an observable sequence that is terminated by an error with the next observable sequence.
 * @see [catch operator on reactivex.io](http://reactivex.io/documentation/operators/catch.html)
 * @return: An observable sequence containing elements from consecutive source sequences until a source sequence terminates successfully.
 */
- (nonnull RxObservable<E> *)catchError;

@end

@interface NSSet<E> (RxCatch)
- (nonnull RxObservable<E> *)catchError;
@end

@interface NSEnumerator<E> (RxCatch)
- (nonnull RxObservable<E> *)catchError;
@end

@interface RxObservable<E> (TakeUntil)
/**
 * Returns the elements from the source observable sequence until the other observable sequence produces an element.
 * @see [takeUntil operator on reactivex.io](http://reactivex.io/documentation/operators/takeuntil.html)
 * @param other: Observable sequence that terminates propagation of elements of the source sequence.
 * @return: An observable sequence containing the elements of the source sequence up to the point the other sequence interrupted further propagation.
 */
- (nonnull RxObservable<E> *)takeUntil:(nonnull id <RxObservableType>)other;

@end

@interface RxObservable<E> (SkipUntil)
/**
 * Returns the elements from the source observable sequence that are emitted after the other observable sequence produces an element.
 * @see [skipUntil operator on reactivex.io](http://reactivex.io/documentation/operators/skipuntil.html)
 * @param other: Observable sequence that starts propagation of elements of the source sequence.
 * @return: An observable sequence containing the elements of the source sequence that are emitted after the other sequence emits an item.
 */
- (nonnull RxObservable<E> *)skipUntil:(nonnull id <RxObservableType>)other;

@end

@interface RxObservable<E> (Amb)
/**
 * Propagates the observable sequence that reacts first.
 * @see [amb operator on reactivex.io](http://reactivex.io/documentation/operators/amb.html)
 * @param right: Second observable sequence.
 * @return: An observable sequence that surfaces either of the given sequences, whichever reacted first.
 */
- (nonnull RxObservable<E> *)amb:(nonnull id <RxObservableType>)right;

@end

@interface NSArray<E> (RxAmb)
/**
 * Propagates the observable sequence that reacts first.
 * @see [amb operator on reactivex.io](http://reactivex.io/documentation/operators/amb.html)
 * @return: An observable sequence that surfaces any of the given sequences, whichever reacted first.
 */
- (nonnull RxObservable<E> *)amb;

@end

@interface NSSet<E> (RxAmb)
- (nonnull RxObservable<E> *)amb;
@end

@interface NSEnumerator<E> (RxAmb)
- (nonnull RxObservable<E> *)amb;
@end

@interface RxObservable<E> (WithLatestFrom)
/**
 * Merges two observable sequences into one observable sequence by combining each element from self with the latest element from the second source, if any.
 * @see [combineLatest operator on reactivex.io](http://reactivex.io/documentation/operators/combinelatest.html)
 * @param second: Second observable source.
 * @param resultSelector: Function to invoke for each element from the self combined with the latest element from the second source, if any.
 * @return: An observable sequence containing the result of combining each element of the self  with the latest element from the second source, if any, using the specified result selector function.
 */
- (nonnull RxObservable<E> *)withLatestFrom:(nonnull id <RxObservableConvertibleType>)second
                             resultSelector:(E __nonnull (^)(id __nonnull x, id __nonnull y))resultSelector;

/**
 * Merges two observable sequences into one observable sequence by using latest element from the second sequence every time when `self` emitts an element.
 * @see [combineLatest operator on reactivex.io](http://reactivex.io/documentation/operators/combinelatest.html)
 * @param second: Second observable source.
 * @return: An observable sequence containing the result of combining each element of the self  with the latest element from the second source, if any, using the specified result selector function.
 */
- (nonnull RxObservable<E> *)withLatestFrom:(nonnull id <RxObservableConvertibleType>)second;

@end


NS_ASSUME_NONNULL_END