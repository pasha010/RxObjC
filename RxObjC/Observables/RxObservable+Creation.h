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

@class RxAnyObserver;

NS_ASSUME_NONNULL_BEGIN

@interface RxObservable (Create)

/**
Creates an observable sequence from a specified subscribe method implementation.

- seealso: [create operator on reactivex.io](http://reactivex.io/documentation/operators/create.html)

- parameter subscribe: Implementation of the resulting observable sequence's `subscribe` method.
- returns: The observable sequence with the specified implementation for the `subscribe` method.
*/
+ (nonnull instancetype)create:(RxAnonymousSubscribeHandler)subscribe;

@end

@interface RxObservable (Fail)
/**
Returns an observable sequence that terminates with an `error`.

- seealso: [throw operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

- returns: The observable sequence that terminates with specified error.
*/
+ (nonnull instancetype)error:(nonnull NSError *)error;
@end

NS_ASSUME_NONNULL_END