//
//  RxSingle
//  RxObjC
// 
//  Created by Pavel Malkov on 30.08.17.
//  Copyright (c) 2014-2017 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxPrimitiveSequence.h"

@protocol RxDisposable;
@protocol RxSingleObserver;

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents a push style sequence containing 1 element.
 */
@interface RxSingle<__covariant Element> : RxPrimitiveSequence<Element>
@end

@interface RxSingle<__covariant Element> (Creation)

/**
 * Creates an observable sequence from a specified subscribe method implementation.
 * @param subscribe Implementation of the resulting observable sequence's `subscribe` method.
 * @return The observable sequence with the specified implementation for the `subscribe` method.
 */
+ (nonnull instancetype)create:(id <RxDisposable>(^ _Nonnull)(id <RxSingleObserver> observer))subscribe;

/**
 * Subscribes a success handler, and an error handler for this sequence.
 * @param success Action to invoke for each element in the observable sequence.
 * @param error Action to invoke upon errored termination of the observable sequence.
 * @return Subscription object used to unsubscribe from the observable sequence.
 */
- (nonnull id <RxDisposable>)subscribeOnSuccess:(void (^ _Nullable)(Element))success
                                        onError:(void (^ _Nullable)(NSError *))error;

- (nonnull id <RxDisposable>)subscribeOnSuccess:(void (^ _Nullable)(Element))success;

@end

@interface RxObservable<__covariant Element> (AsSingle)

/**
 * The `asSingle` operator throws a `RxError.noElements` or `RxError.moreThanOneElement`
 * if the source Observable does not emit exactly one element before successfully completing.
 * @return An observable sequence that emits a single element or throws an exception if more (or none) of them are emitted.
 */
- (nonnull RxSingle<Element> *)asSingle;

/**
 * The `first` operator emits only the very first item emitted by this Observable,
 * or nil if this Observable completes without emitting anything.
 * @return An observable sequence that emits a single element or nil if the source observable sequence completes without emitting any items.
 */
- (nonnull RxSingle<Element> *)first;

@end

/**
 * Observer for single events
 */
@protocol RxSingleObserver <NSObject>

- (void)onSuccess:(id)element;

- (void)onError:(NSError *)error;
@end

NS_ASSUME_NONNULL_END