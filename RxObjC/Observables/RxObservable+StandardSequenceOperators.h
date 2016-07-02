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
Filters the elements of an observable sequence based on a predicate.

- seealso: [filter operator on reactivex.io](http://reactivex.io/documentation/operators/filter.html)

- parameter predicate: A function to test each source element for a condition.
- returns: An observable sequence that contains elements from the input sequence that satisfy the condition.
*/
- (nonnull RxObservable *)filter:(nonnull BOOL(^)(id __nonnull))predicate;
@end

@interface NSObject (RxTakeWhile) <RxObservableType>
/**
Returns elements from an observable sequence as long as a specified condition is true.

- seealso: [takeWhile operator on reactivex.io](http://reactivex.io/documentation/operators/takewhile.html)

- parameter predicate: A function to test each element for a condition.
- returns: An observable sequence that contains the elements from the input sequence that occur before the element at which the test no longer passes.
*/
- (nonnull RxObservable *)takeWhile:(nonnull BOOL(^)(id __nonnull))predicate;

/**
Returns elements from an observable sequence as long as a specified condition is true.

The element's index is used in the logic of the predicate function.

- seealso: [takeWhile operator on reactivex.io](http://reactivex.io/documentation/operators/takewhile.html)

- parameter predicate: A function to test each element for a condition; the second parameter of the function represents the index of the source element.
- returns: An observable sequence that contains the elements from the input sequence that occur before the element at which the test no longer passes.
*/
- (nonnull RxObservable *)takeWhileWithIndex:(nonnull BOOL(^)(id __nonnull, NSUInteger))predicate;

@end

@interface NSObject (RxMap) <RxObservableType>
/**
Projects each element of an observable sequence into a new form.

- seealso: [map operator on reactivex.io](http://reactivex.io/documentation/operators/map.html)

- parameter selector: A transform function to apply to each source element.
- returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.

*/
- (nonnull RxObservable *)map:(RxMapSelector)mapSelector;

/**
Projects each element of an observable sequence into a new form by incorporating the element's index.

- seealso: [map operator on reactivex.io](http://reactivex.io/documentation/operators/map.html)

- parameter selector: A transform function to apply to each source element; the second parameter of the function represents the index of the source element.
- returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
*/
- (nonnull RxObservable *)mapWithIndex:(RxMapWithIndexSelector)mapSelector;

@end

@interface NSObject (RxFlatMap) <RxObservableType>

@end

NS_ASSUME_NONNULL_END