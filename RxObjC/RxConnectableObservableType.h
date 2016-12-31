//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservableType.h"
#import "RxObservable.h"

NS_ASSUME_NONNULL_BEGIN

@class RxConnectableObservable<E>;

/**
Represents an observable sequence wrapper that can be connected and disconnected from its underlying observable sequence.
*/
@protocol RxConnectableObservableType <RxObservableType>
/**
Connects the observable wrapper to its source. All subscribed observers will receive values from the underlying observable sequence as long as the connection is established.

- returns: Disposable used to disconnect the observable wrapper from its source, causing subscribed observer to stop receiving values from the underlying observable sequence.
*/
- (nonnull id <RxDisposable>)connect;

- (nonnull RxConnectableObservable<id> *)asConnectableObservable;

@end

/**
 * Represents an observable wrapper that can be connected and disconnected from its underlying observable sequence.
 */
@interface RxConnectableObservable<Element> : RxObservable<Element> <RxConnectableObservableType>

/**
 * Connects the observable wrapper to its source. All subscribed observers will receive values from the underlying observable sequence as long as the connection is established.
 * @return - Disposable used to disconnect the observable wrapper from its source, causing subscribed observer to stop receiving values from the underlying observable sequence.
*/
- (nonnull id <RxDisposable>)connect;

@end

@interface RxConnectableObservableAdapter<__covariant S : id <RxSubjectType>, E> : RxConnectableObservable<E>

- (nonnull instancetype)initWithSource:(nonnull RxObservable<E> *)source andSubject:(nonnull S)subject;

@end

NS_ASSUME_NONNULL_END