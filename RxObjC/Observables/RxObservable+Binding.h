//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservable.h"
#import "RxObservableBlockTypedef.h"
#import "RxConnectableObservableType.h"

@protocol RxSubjectType;

NS_ASSUME_NONNULL_BEGIN

@interface RxObservable<E> (Multicast)
/**
 * Multicasts the source sequence notifications through the specified subject to the resulting connectable observable.
 * Upon connection of the connectable observable, the subject is subscribed to the source exactly one, and messages are forwarded to the observers registered with the connectable observable.
 * For specializations with fixed subject types, see `publish` and `replay`.
 * @see [multicast operator on reactivex.io](http://reactivex.io/documentation/operators/publish.html)
 * @param subject - Subject to push source elements into.
 * @return: A connectable observable sequence that upon connection causes the source sequence to push results into the specified subject.
 */
- (nonnull RxConnectableObservable<E> *)multicast:(nonnull id <RxSubjectType>)subject;

/**
 * Multicasts the source sequence notifications through an instantiated subject into all uses of the sequence within a selector function.
 * Each subscription to the resulting sequence causes a separate multicast invocation, exposing the sequence resulting from the selector function's invocation.
 * For specializations with fixed subject types, see `publish` and `replay`.
 * @see [multicast operator on reactivex.io](http://reactivex.io/documentation/operators/publish.html)
 * @param subjectSelector - Factory function to create an intermediate subject through which the source sequence's elements will be multicast to the selector function.
 * @param sel - Selector function which can use the multicasted source sequence subject to the policies enforced by the created subject.
 * @return: An observable sequence that contains the elements of a sequence produced by multicasting the source sequence within a selector function.
 */
- (nonnull RxObservable<E> *)multicast:(RxSubjectSelectorType)subjectSelector selector:(RxSelectorType)sel;

@end

@interface RxObservable<E> (Publish)
/**
 * Returns a connectable observable sequence that shares a single subscription to the underlying sequence.
 * This operator is a specialization of `multicast` using a `PublishSubject`.
 * @see [publish operator on reactivex.io](http://reactivex.io/documentation/operators/publish.html)
 * @return: A connectable observable sequence that shares a single subscription to the underlying sequence.
 */
- (nonnull RxConnectableObservable<E> *)publish;

@end

@interface RxObservable<E> (Replay)
/**
 * Returns a connectable observable sequence that shares a single subscription to the underlying sequence replaying bufferSize elements.
 * This operator is a specialization of `multicast` using a `ReplaySubject`.
 * @see [replay operator on reactivex.io](http://reactivex.io/documentation/operators/replay.html)
 * @param bufferSize - Maximum element count of the replay buffer.
 * @return: A connectable observable sequence that shares a single subscription to the underlying sequence.
 */
- (nonnull RxConnectableObservable<E> *)replay:(NSUInteger)bufferSize;

/**
 * Returns a connectable observable sequence that shares a single subscription to the underlying sequence replaying all elements.
 * This operator is a specialization of `multicast` using a `ReplaySubject`.
 * @see [replay operator on reactivex.io](http://reactivex.io/documentation/operators/replay.html)
 * @return: A connectable observable sequence that shares a single subscription to the underlying sequence.
 */
- (nonnull RxConnectableObservable<E> *)replayAll;

@end

@interface RxConnectableObservable<E> (Refcount)
/**
 * Returns an observable sequence that stays connected to the source as long as there is at least one subscription to the observable sequence.
 * @see [refCount operator on reactivex.io](http://reactivex.io/documentation/operators/refCount.html)
 * @return: An observable sequence that stays connected to the source as long as there is at least one subscription to the observable sequence.
 */
- (nonnull RxObservable<E> *)refCount;

@end

@interface RxObservable<E> (Share)
/**
 * Returns an observable sequence that shares a single subscription to the underlying sequence.
 * This operator is a specialization of publish which creates a subscription when the number of observers goes from zero to one, then shares that subscription with all subsequent observers until the number of observers returns to zero, at which point the subscription is disposed.
 * @see [share operator on reactivex.io](http://reactivex.io/documentation/operators/refcount.html)
 * @return: An observable sequence that contains the elements of a sequence produced by multicasting the source sequence.
 */
- (nonnull RxObservable<E> *)share;

@end

@interface RxObservable<E> (ShareReplay)
/**
 * Returns an observable sequence that shares a single subscription to the underlying sequence, and immediately upon subscription replays maximum number of elements in buffer.
 * This operator is a specialization of replay which creates a subscription when the number of observers goes from zero to one, then shares that subscription with all subsequent observers until the number of observers returns to zero, at which point the subscription is disposed.
 * @see [shareReplay operator on reactivex.io](http://reactivex.io/documentation/operators/replay.html)
 * @param bufferSize - Maximum element count of the replay buffer.
 * @return: An observable sequence that contains the elements of a sequence produced by multicasting the source sequence.
 */
- (nonnull RxObservable<E> *)shareReplay:(NSUInteger)bufferSize;

/**
 * Returns an observable sequence that shares a single subscription to the underlying sequence, and immediately upon subscription replays latest element in buffer.
 * This operator is a specialization of replay which creates a subscription when the number of observers goes from zero to one, then shares that subscription with all subsequent observers until the number of observers returns to zero, at which point the subscription is disposed.
 * Unlike shareReplay(bufferSize: Int)`, this operator will clear latest element from replay buffer in case number of subscribers drops from one to zero. In case sequence
 * completes or errors out replay buffer is also cleared.
 * @see [shareReplay operator on reactivex.io](http://reactivex.io/documentation/operators/replay.html)
 * @return: An observable sequence that contains the elements of a sequence produced by multicasting the source sequence.
 */
- (nonnull RxObservable<E> *)shareReplayLatestWhileConnected;

@end

NS_ASSUME_NONNULL_END