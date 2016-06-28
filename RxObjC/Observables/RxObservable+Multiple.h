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

NS_ASSUME_NONNULL_BEGIN

@interface RxObservable (Concat)
/**
Concatenates the second observable sequence to `self` upon successful termination of `self`.

- seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

- parameter second: Second observable sequence.
- returns: An observable sequence that contains the elements of `self`, followed by those of the second sequence.
*/
+ (nonnull RxObservable *)concatWith:(nonnull RxObservable *)second;

@end

@interface NSArray (RxConcat)
/**
Concatenates all observable sequences in the given sequence, as long as the previous observable sequence terminated successfully.

This operator has tail recursive optimizations that will prevent stack overflow and enable generating
 infinite observable sequences while using limited amount of memory during generation.

Optimizations will be performed in cases equivalent to following:

    [1, [2, [3, .....].concat()].concat].concat()

- seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

- returns: An observable sequence that contains the elements of each given sequence, in sequential order.
*/
- (nonnull RxObservable *)concat;

@end

@interface NSSet (RxConcat)
- (nonnull RxObservable *)concat;
@end

@interface NSEnumerator (RxConcat)
- (nonnull RxObservable *)concat;
@end

@interface NSObject (RxConcat) <RxObservableType>
/**
Concatenates all inner observable sequences, as long as the previous observable sequence terminated successfully.

- seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

- returns: An observable sequence that contains the elements of each observed inner sequence, in sequential order.
*/
+ (nonnull RxObservable *)concat;

@end

@interface NSObject (RxMerge) <RxObservableType>

/**
Merges elements from all observable sequences in the given enumerable sequence into a single observable sequence.

- seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)

- returns: The observable sequence that merges the elements of the observable sequences.
*/
- (nonnull RxObservable *)merge;

/**
Merges elements from all inner observable sequences into a single observable sequence, limiting the number of concurrent subscriptions to inner sequences.

- seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)

- parameter maxConcurrent: Maximum number of inner observable sequences being subscribed to concurrently.
- returns: The observable sequence that merges the elements of the inner sequences.
*/
- (nonnull RxObservable *)merge:(NSUInteger)maxConcurrent;
@end

@interface NSObject (RxCatch) <RxObservableType>
/**
Continues an observable sequence that is terminated by an error with the observable sequence produced by the handler.

- seealso: [catch operator on reactivex.io](http://reactivex.io/documentation/operators/catch.html)

- parameter handler: Error handler function, producing another observable sequence.
- returns: An observable sequence containing the source sequence's elements, followed by the elements produced by the handler's resulting observable sequence in case an error occurred.
*/
- (nonnull RxObservable *)catchError:(RxObservable *(^)(NSError *))handler;

/**
Continues an observable sequence that is terminated by an error with a single element.

- seealso: [catch operator on reactivex.io](http://reactivex.io/documentation/operators/catch.html)

- parameter element: Last element in an observable sequence in case error occurs.
- returns: An observable sequence containing the source sequence's elements, followed by the `element` in case an error occurred.
*/
- (nonnull RxObservable *)catchErrorJustReturn:(nonnull id)element;

@end

@interface NSArray (RxCatch)
/**
Continues an observable sequence that is terminated by an error with the next observable sequence.

- seealso: [catch operator on reactivex.io](http://reactivex.io/documentation/operators/catch.html)

- returns: An observable sequence containing elements from consecutive source sequences until a source sequence terminates successfully.
*/
- (nonnull RxObservable *)catchError;

@end

@interface NSSet (RxCatch)
- (nonnull RxObservable *)catchError;
@end

@interface NSEnumerator (RxCatch)
- (nonnull RxObservable *)catchError;
@end

@interface NSObject (RxTakeUntil) <RxObservableType>
/**
Returns the elements from the source observable sequence until the other observable sequence produces an element.

- seealso: [takeUntil operator on reactivex.io](http://reactivex.io/documentation/operators/takeuntil.html)

- parameter other: Observable sequence that terminates propagation of elements of the source sequence.
- returns: An observable sequence containing the elements of the source sequence up to the point the other sequence interrupted further propagation.
*/
- (nonnull RxObservable *)takeUntil:(nonnull id <RxObservableType>)other;

@end

@interface NSObject (RxSkipUntil) <RxObservableType>
/**
Returns the elements from the source observable sequence that are emitted after the other observable sequence produces an element.

- seealso: [skipUntil operator on reactivex.io](http://reactivex.io/documentation/operators/skipuntil.html)

- parameter other: Observable sequence that starts propagation of elements of the source sequence.
- returns: An observable sequence containing the elements of the source sequence that are emitted after the other sequence emits an item.
*/
- (nonnull RxObservable *)skipUntil:(nonnull id <RxObservableType>)other;

@end


NS_ASSUME_NONNULL_END