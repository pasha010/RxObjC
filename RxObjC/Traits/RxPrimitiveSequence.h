//
//  RxPrimitiveSequence
//  RxObjC
// 
//  Created by Pavel Malkov on 30.08.17.
//  Copyright (c) 2014-2017 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservableConvertibleType.h"

@class RxObservable<E>;
@protocol RxImmediateSchedulerType;
@class RxMaybe<E>;

typedef NSString *RxPrimitiveTrait NS_STRING_ENUM;

NS_ASSUME_NONNULL_BEGIN

@interface RxPrimitiveSequence<__covariant Element> : NSObject <RxObservableConvertibleType>

@property (nonnull, strong, readonly) RxObservable<Element> *source;
@property (readonly) RxPrimitiveTrait trait;

- (instancetype)initWithSource:(RxObservable *)source;

- (nonnull RxObservable<Element> *)asObservable;

@end

@interface RxPrimitiveSequence<__covariant Element> (Extension)

/**
 * Returns an observable sequence that invokes the specified factory function whenever a new observer subscribes.
 * @param observableFactory Observable factory function to invoke for each observer that subscribes to the resulting sequence.
 * @return An observable sequence whose observers trigger an invocation of the given observable factory function.
 */
+ (nonnull instancetype)deferred:(RxPrimitiveSequence<id> *(^ _Nonnull)(void))observableFactory;

/**
 * Returns an observable sequence that contains a single element.
 * @param element Single element in the resulting observable sequence.
 * @return An observable sequence containing the single specified element.
 */
+ (nonnull instancetype)just:(Element)element;

/**
 * Returns an observable sequence that contains a single element.
 * @param element Single element in the resulting observable sequence.
 * @param scheduler Scheduler to send the single element on.
 * @return An observable sequence containing the single specified element.
 */
+ (nonnull instancetype)just:(Element)element scheduler:(nonnull id <RxImmediateSchedulerType>)scheduler;

/**
 * Returns an observable sequence that terminates with an `error`.
 * @return The observable sequence that terminates with specified error.
 */
+ (nonnull instancetype)error:(NSError *)error;

/**
 * Returns a non-terminating observable sequence, which can be used to denote an infinite duration.
 * @return An observable sequence whose observers will never get called.
 */
+ (nonnull instancetype)never;

/**
 * Time shifts the observable sequence by delaying the subscription with the specified relative time duration,
 * using the specified scheduler to run timers.
 * @param dueTime Relative time shift of the subscription.
 * @param scheduler Scheduler to run the subscription delay timer on.
 * @return Time-shifted sequence.
 */
- (nonnull instancetype)delaySubscription:(RxTimeInterval)dueTime scheduler:(nonnull id <RxSchedulerType>)scheduler;

/**
 * Invokes an action for each event in the observable sequence, and propagates all observer messages through the result sequence.
 * @param onNext Action to invoke for each element in the observable sequence.
 * @param onError Action to invoke upon errored termination of the observable sequence.
 * @param onCompleted Action to invoke upon graceful termination of the observable sequence.
 * @return
 */
- (nonnull instancetype)doOnNext:(void (^ _Nullable)(Element value))onNext
                         onError:(void (^ _Nullable)(NSError *))onError
                     onCompleted:(void (^ _Nullable)())onCompleted;

- (nonnull instancetype)doOnNext:(void (^ _Nullable)(Element value))onNext;

- (nonnull instancetype)doOnError:(void (^ _Nullable)(NSError *))onError;

- (nonnull instancetype)doOnCompleted:(void (^ _Nullable)())onCompleted;

/**
 * Filters the elements of an observable sequence based on a predicate.
 * @param predicate A function to test each source element for a condition.
 * @return An observable sequence that contains elements from the input sequence that satisfy the condition.
 */
- (nonnull RxMaybe<Element> *)filter:(BOOL(^ _Nonnull)(Element _Nonnull))predicate;

/**
 * Projects each element of an observable sequence into a new form.
 * @param transform A transform function to apply to each source element.
 * @return An observable sequence whose elements are the result of invoking the transform function on each element of source.
 */
- (nonnull __kindof RxPrimitiveSequence<id> *)map:(id(^ _Nonnull)(Element _Nonnull))transform;

/**
 * Projects each element of an observable sequence to an observable sequence and merges
 * the resulting observable sequences into one observable sequence.
 * @param block A transform function to apply to each element.
 * @return An observable sequence whose elements are the result of invoking the one-to-many transform
 *         function on each element of the input sequence.
 */
- (nonnull __kindof RxPrimitiveSequence<id> *)flatMap:(__kindof RxPrimitiveSequence<id> *(^ _Nonnull)(Element _Nonnull element))block;

/**
 * Wraps the source sequence in order to run its observer callbacks on the specified scheduler.
 * This only invokes observer callbacks on a `scheduler`. In case the subscription and/or unsubscription
 * actions have side-effects that require to be run on a scheduler, use `subscribeOn`.
 * @param scheduler Scheduler to notify observers on.
 * @return The source sequence whose observations happen on the specified scheduler.
 */
- (nonnull instancetype)observeOn:(nonnull RxImmediateScheduler *)scheduler;

- (nonnull instancetype)observeOnMainThread;

/**
 * Wraps the source sequence in order to run its subscription and unsubscription logic on the specified scheduler.
 * This operation is not commonly used.
 * This only performs the side-effects of subscription and unsubscription on the specified scheduler.
 * In order to invoke observer callbacks on a `scheduler`, use `observeOn`.
 * @param scheduler Scheduler to perform subscription and unsubscription actions on.
 * @return The source sequence whose subscriptions and unsubscriptions happen on the specified scheduler.
 */
- (nonnull instancetype)subscribeOn:(nonnull id <RxImmediateSchedulerType>)scheduler;

/**
 * Continues an observable sequence that is terminated by an error with the observable sequence produced by the handler.
 * @param handler Error handler function, producing another observable sequence.
 * @return An observable sequence containing the source sequence's elements, followed by the elements produced by the handler's resulting observable sequence in case an error occurred.
 */
- (nonnull instancetype)catchError:(__kindof RxPrimitiveSequence<Element> *(^ _Nonnull)(NSError *_Nonnull))handler;

/**
 * Repeats the source observable sequence the specified number of times in case of an error or until it successfully terminates.
 * If you encounter an error and want it to retry once, then you must use `retry(2)`
 * @param maxAttemptCount Maximum number of times to repeat the sequence.
 * @return An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully.
 */
- (nonnull instancetype)retry:(NSUInteger)maxAttemptCount;

/**
 * Repeats the source observable sequence on error when the notifier emits a next value.
 * If the source observable errors and the notifier completes, it will complete the source sequence.
 * @param notificationHandler A handler that is passed an observable sequence of errors raised by the source observable and returns and observable that either continues, completes or errors. This behavior is then applied to the source observable.
 * @return An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully or is notified to error or complete.
 */
- (nonnull instancetype)retryWhen:(id <RxObservableType>(^ _Nonnull)(RxObservable<__kindof NSError *> *_Nonnull))notificationHandler;

- (nonnull instancetype)retryWhen:(id <RxObservableType>(^ _Nonnull)(RxObservable<__kindof NSError *> *_Nonnull))notificationHandler
                 customErrorClass:(nullable Class)errorClass;

/**
 * Prints received events for all observers on standard output.
 * @param identifier Identifier that is printed together with event description to standard output.
 * @return An observable sequence whose events are printed to standard output.
 */
- (nonnull instancetype)debug:(nonnull NSString *)identifier;

- (nonnull instancetype)timeout:(RxTimeInterval)dueTime scheduler:(nonnull id <RxSchedulerType>)scheduler;

- (nonnull instancetype)timeout:(RxTimeInterval)dueTime
                          other:(nonnull id <RxObservableConvertibleType>)other
                      scheduler:(nonnull id <RxSchedulerType>)scheduler;

/**
 * Returns an observable sequence that periodically produces a value after the specified initial relative due time has elapsed, using the specified scheduler to run timers.
 * @param dueTime Relative time at which to produce the first value.
 * @param scheduler Scheduler to run timers on.
 * @return An observable sequence that produces a value after due time has elapsed and then each period.
 */
+ (nonnull instancetype)timer:(RxTimeInterval)dueTime scheduler:(nonnull id <RxSchedulerType>)scheduler;

/**
 * Merges the specified observable sequences into one observable sequence of tuples whenever
 * all of the observable sequences have produced an element at a corresponding index.
 * @return An observable sequence containing the result of combining elements of the sources using the specified result selector function.
 */
+ (nonnull RxPrimitiveSequence<RxTuple *> *)zip:(nonnull NSArray<__kindof RxPrimitiveSequence<id> *> *)sources;

@end

NS_ASSUME_NONNULL_END