//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservableType.h"
#import "RxSubjectType.h"
#import "RxConnectableObservable.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (RxMulticast) <RxObservableType>
/**
Multicasts the source sequence notifications through the specified subject to the resulting connectable observable.

Upon connection of the connectable observable, the subject is subscribed to the source exactly one, and messages are forwarded to the observers registered with the connectable observable.

For specializations with fixed subject types, see `publish` and `replay`.

- seealso: [multicast operator on reactivex.io](http://reactivex.io/documentation/operators/publish.html)

- parameter subject: Subject to push source elements into.
- returns: A connectable observable sequence that upon connection causes the source sequence to push results into the specified subject.
*/
- (nonnull RxConnectableObservable<id <RxSubjectType>> *)multicast:(nonnull id <RxSubjectType>)subject;

@end

@interface NSObject (RxPublish) <RxObservableType>

@end

@interface NSObject (RxReplay) <RxObservableType>

@end

@interface NSObject (RxRefcount) <RxObservableType>

@end

@interface NSObject (RxShare) <RxObservableType>

@end

@interface NSObject (RxShareReplay) <RxObservableType>

@end

NS_ASSUME_NONNULL_END