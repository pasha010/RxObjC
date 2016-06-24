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

@interface RxObservable (Create)
/**
Creates an observable sequence from a specified subscribe method implementation.

- seealso: [create operator on reactivex.io](http://reactivex.io/documentation/operators/create.html)

- parameter subscribe: Implementation of the resulting observable sequence's `subscribe` method.
- returns: The observable sequence with the specified implementation for the `subscribe` method.
*/
+ (nonnull RxObservable *)create:(RxAnonymousSubscribeHandler)subscribe;

@end

@interface RxObservable (Empty)
/**
Returns an empty observable sequence, using the specified scheduler to send out the single `Completed` message.

- seealso: [empty operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

- returns: An observable sequence with no elements.
*/
+ (nonnull RxObservable *)empty;

@end

@interface RxObservable (Never)

/**
Returns a non-terminating observable sequence, which can be used to denote an infinite duration.

- seealso: [never operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

- returns: An observable sequence whose observers will never get called.
*/
+ (nonnull RxObservable *)never;

@end

@interface RxObservable (Just)
/**
Returns an observable sequence that contains a single element.

- seealso: [just operator on reactivex.io](http://reactivex.io/documentation/operators/just.html)

- parameter element: Single element in the resulting observable sequence.
- returns: An observable sequence containing the single specified element.
*/
+ (nonnull RxObservable *)just:(nonnull id)element;

/**
Returns an observable sequence that contains a single element.

- seealso: [just operator on reactivex.io](http://reactivex.io/documentation/operators/just.html)

- parameter element: Single element in the resulting observable sequence.
- parameter: Scheduler to send the single element on.
- returns: An observable sequence containing the single specified element.
*/
+ (nonnull RxObservable *)just:(nonnull id)element scheduler:(nonnull id <RxImmediateSchedulerType>)scheduler;

@end

@interface RxObservable (Fail)
/**
Returns an observable sequence that terminates with an `error`.

- seealso: [throw operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

- returns: The observable sequence that terminates with specified error.
*/
+ (nonnull RxObservable *)error:(nonnull NSError *)error;
@end

@interface RxObservable (Of)
/**
This method creates a new Observable instance with a variable number of elements.

- seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

- parameter elements: Elements to generate.
- parameter scheduler: Scheduler to send elements on. If `nil`, elements are sent immediatelly on subscription.
- returns: The observable sequence whose elements are pulled from the given arguments.
*/
+ (nonnull RxObservable *)of:(nonnull NSArray *)elements;

+ (nonnull RxObservable *)of:(nonnull NSArray *)elements scheduler:(nullable id <RxImmediateSchedulerType>)scheduler;
@end

NS_ASSUME_NONNULL_END