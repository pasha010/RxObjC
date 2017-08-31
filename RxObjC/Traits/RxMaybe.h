//
//  RxMaybe
//  RxObjC
// 
//  Created by Pavel Malkov on 30.08.17.
//  Copyright (c) 2014-2017 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxPrimitiveSequence.h"

@class RxMaybeEvent;
@protocol RxDisposable;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT RxPrimitiveTrait const RxPrimitiveTraitMaybe;

/**
 * Represents a push style sequence containing 0 or 1 element.
 */
@interface RxMaybe<__covariant Element> : RxPrimitiveSequence<Element>
@end

typedef void (^RxMaybeObserver)(RxMaybeEvent *_Nonnull event);

@interface RxMaybe<__covariant Element> (Creation)

/**
 * Creates an observable sequence from a specified subscribe method implementation.
 * @param subscribe Implementation of the resulting observable sequence's `subscribe` method.
 * @return The observable sequence with the specified implementation for the `subscribe` method.
 */
+ (nonnull instancetype)create:(id <RxDisposable>(^ _Nonnull)(RxMaybeObserver))subscribe;

/**
 * Subscribes `observer` to receive events for this sequence.
 * @param observer
 * @return Subscription for `observer` that can be used to cancel production of sequence elements and free resources.
 */
- (nonnull id <RxDisposable>)subscribe:(void (^ _Nonnull)(RxMaybeEvent *))observer;

/**
 * Subscribes a success handler, an error handler, and a completion handler for this sequence.
 * @param onSuccess Action to invoke for each element in the observable sequence.
 * @param onError Action to invoke upon errored termination of the observable sequence.
 * @param onCompleted Action to invoke upon graceful termination of the observable sequence.
 * @return Subscription object used to unsubscribe from the observable sequence.
 */
- (nonnull id <RxDisposable>)subscribeOnSuccess:(void (^ _Nullable)(Element))onSuccess
                                        onError:(void (^ _Nullable)(NSError *))onError
                                    onCompleted:(void (^ _Nullable)())onCompleted;

- (nonnull id <RxDisposable>)subscribeOnSuccess:(void (^ _Nullable)(Element))onSuccess;

- (nonnull id <RxDisposable>)subscribeOnSuccess:(void (^ _Nullable)(Element))onSuccess
                                        onError:(void (^ _Nullable)(NSError *))onError;

@end

@interface RxMaybe<__covariant Element> (Extension)

/**
 * Returns an empty observable sequence, using the specified scheduler to send out the single `Completed` message.
 * @return
 */
+ (nonnull instancetype)empty;

@end

@interface RxObservable<__covariant Element> (AsMaybe)

/**
 * The `asMaybe` operator throws a ``RxError.moreThanOneElement`
 * if the source Observable does not emit at most one element before successfully completing.
 * @return An observable sequence that emits a single element, completes or throws an exception if more of them are emitted.
 */
- (nonnull RxMaybe<Element> *)asMaybe;

@end

@interface RxMaybeEvent : NSObject

@property (readonly) BOOL isSuccess;
@property (readonly) BOOL isError;
@property (readonly) BOOL isCompleted;

@end

@interface RxMaybeEventSuccess<__covariant Element> : RxMaybeEvent

@property (nullable, strong, readonly) Element element;

+ (nonnull instancetype)success:(nullable Element)element;

@end

@interface RxMaybeEventError : RxMaybeEvent

@property (nullable, strong, readonly) NSError *error;

+ (nonnull instancetype)error:(NSError *)error;

@end

@interface RxMaybeEventCompleted : RxMaybeEvent

+ (nonnull instancetype)completed;

@end

NS_ASSUME_NONNULL_END