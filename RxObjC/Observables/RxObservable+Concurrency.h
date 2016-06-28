//
//  RxObservable(Concurrency)
//  RxObjC
// 
//  Created by Pavel Malkov on 26.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservable.h"

@protocol RxImmediateSchedulerType;

NS_ASSUME_NONNULL_BEGIN

@interface RxObservable (ObserveOn)
/**
Wraps the source sequence in order to run its observer callbacks on the specified scheduler.

This only invokes observer callbacks on a `scheduler`. In case the subscription and/or unsubscription
actions have side-effects that require to be run on a scheduler, use `subscribeOn`.

- seealso: [observeOn operator on reactivex.io](http://reactivex.io/documentation/operators/observeon.html)

- parameter scheduler: Scheduler to notify observers on.
- returns: The source sequence whose observations happen on the specified scheduler.
*/
- (nonnull RxObservable *)observeOn:(nonnull id <RxImmediateSchedulerType>)scheduler;
@end

@interface RxObservable (SubscribeOn)
/**
Wraps the source sequence in order to run its subscription and unsubscription logic on the specified
scheduler.

This operation is not commonly used.

This only performs the side-effects of subscription and unsubscription on the specified scheduler.

In order to invoke observer callbacks on a `scheduler`, use `observeOn`.

- seealso: [subscribeOn operator on reactivex.io](http://reactivex.io/documentation/operators/subscribeon.html)

- parameter scheduler: Scheduler to perform subscription and unsubscription actions on.
- returns: The source sequence whose subscriptions and unsubscriptions happen on the specified scheduler.
*/
- (nonnull RxObservable *)subscribeOn:(nonnull id <RxImmediateSchedulerType>)scheduler;

@end

NS_ASSUME_NONNULL_END