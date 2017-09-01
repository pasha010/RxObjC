//
//  RxCompletable
//  RxObjC
// 
//  Created by Pavel Malkov on 30.08.17.
//  Copyright (c) 2014-2017 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxPrimitiveSequence.h"

@class RxCompletableEvent;
@protocol RxDisposable;
@class RxSingle<E>;

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents a push style sequence containing 0 elements.
 */
@interface RxCompletable : RxPrimitiveSequence
@end

typedef void (^RxCompletableObserver)(RxCompletableEvent *_Nonnull event);

@interface RxCompletable (Creation)

/**
 * Creates an observable sequence from a specified subscribe method implementation.
 * @param subscribe Implementation of the resulting observable sequence's `subscribe` method.
 * @return The observable sequence with the specified implementation for the `subscribe` method.
 */
+ (nonnull instancetype)create:(id <RxDisposable>(^ _Nonnull)(RxCompletableObserver))subscribe;

/**
 * Subscribes `observer` to receive events for this sequence.
 * @return Subscription for `observer` that can be used to cancel production of sequence elements and free resources.
 */
- (nonnull id <RxDisposable>)subscribe:(void (^ _Nonnull)(RxCompletableEvent *_Nonnull))observer;

/**
 * Subscribes a completion handler and an error handler for this sequence.
 * @param onCompleted Action to invoke upon graceful termination of the observable sequence.
 * @param onError Action to invoke upon errored termination of the observable sequence.
 * @return Subscription object used to unsubscribe from the observable sequence.
 */
- (nonnull id <RxDisposable>)subscribeOnCompleted:(void (^ _Nullable)())onCompleted
                                          onError:(void (^ _Nullable)(NSError *))onError;

- (nonnull id <RxDisposable>)subscribeOnCompleted:(void (^ _Nullable)())onCompleted;

@end

@interface RxCompletable (Extension)

/**
 * Returns an empty observable sequence, using the specified scheduler to send out the single `Completed` message.
 * @return An observable sequence with no elements.
 */
+ (nonnull instancetype)empty;

/**
 * Concatenates all observable sequences in the given sequence, as long as the previous observable sequence terminated successfully.
 * @return An observable sequence that contains the elements of each given sequence, in sequential order.
 */
+ (nonnull instancetype)concat:(nonnull NSArray<RxCompletable *> *)completables;

/**
 * Concatenates the second observable sequence to `self` upon successful termination of `self`.
 * @param completable Second observable sequence.
 * @return An observable sequence that contains the elements of `self`, followed by those of the second sequence.
 */
- (nonnull instancetype)concatWith:(nonnull RxCompletable *)completable;

/**
 * Merges elements from all observable sequences from array into a single observable sequence.
 * @param completables Array of observable sequences to merge.
 * @return The observable sequence that merges the elements of the observable sequences.
 */
+ (nonnull instancetype)merge:(nonnull NSArray<RxCompletable *> *)completables;

@end

@interface RxCompletable (AndThen)

- (nonnull RxSingle<id> *)andThenSingle:(RxSingle<id> *)second;

- (nonnull RxMaybe<id> *)andThenMaybe:(RxMaybe<id> *)second;

- (nonnull RxCompletable *)andThenCompletable:(RxCompletable *)second;

- (nonnull RxObservable<id> *)andThenObservable:(RxObservable<id> *)second;

@end

@interface RxObservable<__covariant Element> (AsCompletable)

- (nonnull RxCompletable *)asCompletable;

@end

@interface RxCompletableEvent : NSObject

@property (readonly) BOOL isCompleted;
@property (readonly) BOOL isError;

@end

@interface RxCompletableEventError : RxCompletableEvent

@property (nullable, strong, readonly) NSError *error;

+ (nonnull instancetype)error:(NSError *)error;

@end

@interface RxCompletableEventCompleted : RxCompletableEvent

+ (nonnull instancetype)completed;

@end


NS_ASSUME_NONNULL_END