//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservableType.h"
#import "RxSubjectType.h"
#import "RxConnectableObservable.h"
#import "RxObservableBlockTypedef.h"

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

/**
Multicasts the source sequence notifications through an instantiated subject into all uses of the sequence within a selector function.

Each subscription to the resulting sequence causes a separate multicast invocation, exposing the sequence resulting from the selector function's invocation.

For specializations with fixed subject types, see `publish` and `replay`.

- seealso: [multicast operator on reactivex.io](http://reactivex.io/documentation/operators/publish.html)

- parameter subjectSelector: Factory function to create an intermediate subject through which the source sequence's elements will be multicast to the selector function.
- parameter selector: Selector function which can use the multicasted source sequence subject to the policies enforced by the created subject.
- returns: An observable sequence that contains the elements of a sequence produced by multicasting the source sequence within a selector function.
*/
/// public func multicast<S: SubjectType, R where S.SubjectObserverType.E == E>(subjectSelector: () throws -> S, selector: (Observable<S.E>) throws -> Observable<R>)

- (nonnull RxObservable<id> *)multicast:(RxSubjectSelectorType)subjectSelector selector:(RxSelectorType)sel;

@end

@interface NSObject (RxPublish) <RxObservableType>
/**
Returns a connectable observable sequence that shares a single subscription to the underlying sequence.

This operator is a specialization of `multicast` using a `PublishSubject`.

- seealso: [publish operator on reactivex.io](http://reactivex.io/documentation/operators/publish.html)

- returns: A connectable observable sequence that shares a single subscription to the underlying sequence.
*/
- (nonnull RxConnectableObservable<id> *)publish;

@end

@interface NSObject (RxReplay) <RxObservableType>
/**
Returns a connectable observable sequence that shares a single subscription to the underlying sequence replaying bufferSize elements.

This operator is a specialization of `multicast` using a `ReplaySubject`.

- seealso: [replay operator on reactivex.io](http://reactivex.io/documentation/operators/replay.html)

- parameter bufferSize: Maximum element count of the replay buffer.
- returns: A connectable observable sequence that shares a single subscription to the underlying sequence.
*/
- (nonnull RxConnectableObservable<id> *)replay:(NSUInteger)bufferSize;

/**
Returns a connectable observable sequence that shares a single subscription to the underlying sequence replaying all elements.

This operator is a specialization of `multicast` using a `ReplaySubject`.

- seealso: [replay operator on reactivex.io](http://reactivex.io/documentation/operators/replay.html)

- returns: A connectable observable sequence that shares a single subscription to the underlying sequence.
*/
- (nonnull RxConnectableObservable<id> *)replayAll;
@end

@interface NSObject (RxRefcount) <RxConnectableObservableType>
/**
Returns an observable sequence that stays connected to the source as long as there is at least one subscription to the observable sequence.

- seealso: [refCount operator on reactivex.io](http://reactivex.io/documentation/operators/refCount.html)

- returns: An observable sequence that stays connected to the source as long as there is at least one subscription to the observable sequence.
*/
- (nonnull RxObservable *)refCount;

@end

@interface NSObject (RxShare) <RxObservableType>

@end

@interface NSObject (RxShareReplay) <RxObservableType>

@end

NS_ASSUME_NONNULL_END