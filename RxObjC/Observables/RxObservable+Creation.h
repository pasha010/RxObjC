//
//  RxObservable(Creation)
//  RxObjC
// 
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservable.h"
#import "RxObservableBlockTypedef.h"
#import "RxObservable+Extension.h"

@class RxAnyObserver;
@protocol RxImmediateSchedulerType;

NS_ASSUME_NONNULL_BEGIN

@interface RxObservable<E> (Create)
/**
Creates an observable sequence from a specified subscribe method implementation.

- seealso: [create operator on reactivex.io](http://reactivex.io/documentation/operators/create.html)

- parameter subscribe: Implementation of the resulting observable sequence's `subscribe` method.
- returns: The observable sequence with the specified implementation for the `subscribe` method.
*/
+ (nonnull RxObservable<E> *)create:(RxAnonymousSubscribeHandler)subscribe;

@end

@interface RxObservable<E> (Empty)
/**
Returns an empty observable sequence, using the specified scheduler to send out the single `Completed` message.

- seealso: [empty operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

- returns: An observable sequence with no elements.
*/
+ (nonnull RxObservable<E> *)empty;

@end

@interface RxObservable<E> (Never)

/**
Returns a non-terminating observable sequence, which can be used to denote an infinite duration.

- seealso: [never operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

- returns: An observable sequence whose observers will never get called.
*/
+ (nonnull RxObservable<E> *)never;

@end

@interface RxObservable <E> (Just)
/**
Returns an observable sequence that contains a single element.

- seealso: [just operator on reactivex.io](http://reactivex.io/documentation/operators/just.html)

- parameter element: Single element in the resulting observable sequence.
- returns: An observable sequence containing the single specified element.
*/
+ (nonnull RxObservable<E> *)just:(nonnull E)element;

/**
Returns an observable sequence that contains a single element.

- seealso: [just operator on reactivex.io](http://reactivex.io/documentation/operators/just.html)

- parameter element: Single element in the resulting observable sequence.
- parameter: Scheduler to send the single element on.
- returns: An observable sequence containing the single specified element.
*/
+ (nonnull RxObservable<E> *)just:(nonnull E)element scheduler:(nonnull id <RxImmediateSchedulerType>)scheduler;

@end

@interface RxObservable (Fail)
/**
Returns an observable sequence that terminates with an `error`.

- seealso: [throw operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

- returns: The observable sequence that terminates with specified error.
*/
+ (nonnull RxObservable *)error:(nonnull NSError *)error;
@end

@interface RxObservable<E> (Of)
/**
This method creates a new Observable instance with a variable number of elements.

- seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

- parameter elements: Elements to generate.
- parameter scheduler: Scheduler to send elements on. If `nil`, elements are sent immediatelly on subscription.
- returns: The observable sequence whose elements are pulled from the given arguments.
*/
+ (nonnull RxObservable<E> *)of:(nonnull NSArray<E> *)elements;

+ (nonnull RxObservable<E> *)of:(nonnull NSArray<E> *)elements scheduler:(nullable id <RxImmediateSchedulerType>)scheduler;

@end

@interface RxObservable<E> (Defer)
/**
Returns an observable sequence that invokes the specified factory function whenever a new observer subscribes.

- seealso: [defer operator on reactivex.io](http://reactivex.io/documentation/operators/defer.html)

- parameter observableFactory: Observable factory function to invoke for each observer that subscribes to the resulting sequence.
- returns: An observable sequence whose observers trigger an invocation of the given observable factory function.
*/
+ (nonnull RxObservable<E> *)deferred:(RxObservableFactory)observableFactory;

/**
Generates an observable sequence by running a state-driven loop producing the sequence's elements, using the specified scheduler
to run the loop send out observer messages.

- seealso: [create operator on reactivex.io](http://reactivex.io/documentation/operators/create.html)

- parameter initialState: Initial state.
- parameter condition: Condition to terminate generation (upon returning `false`).
- parameter iterate: Iteration step function.
- parameter scheduler: Scheduler on which to run the generator loop.
- returns: The generated sequence.
*/
+ (nonnull RxObservable<E> *)generate:(nonnull E)initialState
                            condition:(BOOL(^)(E))condition
                            scheduler:(id <RxImmediateSchedulerType>)scheduler
                              iterate:(E(^)(E))iterate;

+ (nonnull RxObservable<E> *)generate:(nonnull E)initialState
                            condition:(BOOL(^)(E))condition
                              iterate:(E(^)(E))iterate;

/**
Generates an observable sequence that repeats the given element infinitely, using the specified scheduler to send out observer messages.

- seealso: [repeat operator on reactivex.io](http://reactivex.io/documentation/operators/repeat.html)

- parameter element: Element to repeat.
- parameter scheduler: Scheduler to run the producer loop on.
- returns: An observable sequence that repeats the given element infinitely.
*/
+ (nonnull RxObservable<E> *)repeatElement:(nonnull E)element
                                 scheduler:(nonnull id <RxImmediateSchedulerType>)scheduler;

+ (nonnull RxObservable<E> *)repeatElement:(nonnull E)element;

/**
Constructs an observable sequence that depends on a resource object, whose lifetime is tied to the resulting observable sequence's lifetime.

- seealso: [using operator on reactivex.io](http://reactivex.io/documentation/operators/using.html)

- parameter resourceFactory: Factory function to obtain a resource object.
- parameter observableFactory: Factory function to obtain an observable sequence that depends on the obtained resource.
- returns: An observable sequence whose lifetime controls the lifetime of the dependent resource object.
*/
+ (nonnull RxObservable<E> *)using:(id <RxDisposable>(^)())resourceFactory
                 observableFactory:(RxObservable<E> *(^)(id <RxDisposable>))observableFactory;

@end

@interface RxObservable (Range)
/**
Generates an observable sequence of integral numbers within a specified range, using the specified scheduler to generate and send out observer messages.

- seealso: [range operator on reactivex.io](http://reactivex.io/documentation/operators/range.html)

- parameter start: The value of the first integer in the sequence.
- parameter count: The number of sequential integers to generate.
- parameter scheduler: Scheduler to run the generator loop on.
- returns: An observable sequence that contains a range of sequential integral numbers.
*/
+ (nonnull RxObservable<NSNumber *> *)range:(nonnull NSNumber *)start
                                      count:(NSUInteger)count
                                  scheduler:(nonnull id <RxImmediateSchedulerType>)scheduler;

+ (nonnull RxObservable<NSNumber *> *)range:(nonnull NSNumber *)start
                                      count:(NSUInteger)count;

@end

@interface NSArray<E> (RxToObservable)
/**
Converts a sequence to an observable sequence.

- seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

- returns: The observable sequence whose elements are pulled from the given enumerable sequence.
*/
- (nonnull RxObservable<E> *)toObservable:(nullable id <RxImmediateSchedulerType>)scheduler;

- (nonnull RxObservable<E> *)toObservable;

@end

@interface NSSet<E> (RxToObservable)
- (nonnull RxObservable<E> *)toObservable:(nullable id <RxImmediateSchedulerType>)scheduler;

- (nonnull RxObservable<E> *)toObservable;
@end

@interface NSEnumerator<E> (RxToObservable)
- (nonnull RxObservable<E> *)toObservable:(nullable id <RxImmediateSchedulerType>)scheduler;

- (nonnull RxObservable<E> *)toObservable;
@end

NS_ASSUME_NONNULL_END