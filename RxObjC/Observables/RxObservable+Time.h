//
//  RxObservable(Time)
//  RxObjC
// 
//  Created by Pavel Malkov on 04.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservable.h"
#import "RxImmediateSchedulerType.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxObservable<E> (Throttle)
/**
 * Ignores elements from an observable sequence which are followed by another element within a specified relative time duration, using the specified scheduler to run throttling timers.
 * `throttle` and `debounce` are synonyms.
 * @see [debounce operator on reactivex.io](http://reactivex.io/documentation/operators/debounce.html)
 * @param dueTime: Throttling duration for each element.
 * @param scheduler: Scheduler to run the throttle timers and send events on.
 * @return: The throttled sequence.
 */
- (nonnull RxObservable<E> *)throttle:(RxTimeInterval)dueTime scheduler:(nonnull id <RxSchedulerType>)scheduler;

/**
 * Ignores elements from an observable sequence which are followed by another element within a specified relative time duration, using the current thread scheduler to run throttling timers.
 * `throttle` and `debounce` are synonyms.
 * @see [debounce operator on reactivex.io](http://reactivex.io/documentation/operators/debounce.html)
 * @param dueTime: Throttling duration for each element.
 * @return: The throttled sequence.
 */
- (nonnull RxObservable<E> *)throttle:(RxTimeInterval)dueTime;

/**
 * Ignores elements from an observable sequence which are followed by another element within a specified relative time duration, using the specified scheduler to run throttling timers.
 * `throttle` and `debounce` are synonyms.
 * @see [debounce operator on reactivex.io](http://reactivex.io/documentation/operators/debounce.html)
 * @param dueTime: Throttling duration for each element.
 * @param scheduler: Scheduler to run the throttle timers and send events on.
 * @return: The throttled sequence.
 */
- (nonnull RxObservable<E> *)debounce:(RxTimeInterval)dueTime scheduler:(nonnull id <RxSchedulerType>)scheduler;

/**
 * Returns an Observable that emits the most recently emitted item (if any) emitted by the source Observable
 * within periodic time intervals, where the intervals are defined on a particular Scheduler.
 * It's like sample but with time interval.
 * @see [sample operator on reactivex.io](http://reactivex.io/documentation/operators/sample.html)
 * @param dueTime: the sampling rate
 * @param scheduler: Scheduler to run the throttle timers and send events on.
 * @return: The throttled sequence.
 */
- (nonnull RxObservable<E> *)throttleFirst:(RxTimeInterval)dueTime scheduler:(nonnull id <RxSchedulerType>)scheduler;

/**
 * Returns an Observable that emits the most recently emitted item (if any) emitted by the source Observable
 * within periodic time intervals, where the intervals are defined on a current thread scheduler.
 * It's like sample but with time interval.
 * @see [sample operator on reactivex.io](http://reactivex.io/documentation/operators/sample.html)
 * @param dueTime: the sampling rate
 * @return: The throttled sequence.
 */
- (nonnull RxObservable<E> *)throttleFirst:(RxTimeInterval)dueTime;

@end

@interface RxObservable<E> (Sample)
/**
 * Samples the source observable sequence using a samper observable sequence producing sampling ticks.
 * Upon each sampling tick, the latest element (if any) in the source sequence during the last sampling interval is sent to the resulting sequence.
 * ** In case there were no new elements between sampler ticks, no element is sent to the resulting sequence. **
 * @see [sample operator on reactivex.io](http://reactivex.io/documentation/operators/sample.html)
 * @param sampler: Sampling tick sequence.
 * @return: Sampled observable sequence.
 */
- (nonnull RxObservable<E> *)sample:(nonnull id <RxObservableType>)sampler;

@end

@interface RxObservable<E> (Interval)
/**
 * Returns an observable sequence that produces a value after each period, using the specified scheduler to run timers and to send out observer messages.
 * @see [interval operator on reactivex.io](http://reactivex.io/documentation/operators/interval.html)
 * @param period: Period for producing the values in the resulting sequence.
 * @param scheduler: Scheduler to run the timer on.
 * @return: An observable sequence that produces a value after each period.
 */
+ (nonnull RxObservable<NSNumber *> *)interval:(RxTimeInterval)period
                                     scheduler:(nonnull id <RxSchedulerType>)scheduler;
@end

@interface RxObservable<E> (Timer)
/**
 * Returns an observable sequence that periodically produces a value after the specified initial relative due time has elapsed, using the specified scheduler to run timers.
 * @see [timer operator on reactivex.io](http://reactivex.io/documentation/operators/timer.html)
 * @param dueTime: Relative time at which to produce the first value.
 * @param period: Period to produce subsequent values.
 * @param scheduler: Scheduler to run timers on.
 * @return: An observable sequence that produces a value after due time has elapsed and then each period.
 */
+ (nonnull RxObservable<NSNumber *> *)timer:(RxTimeInterval)dueTime
                                     period:(RxTimeInterval)period
                                  scheduler:(nonnull id <RxSchedulerType>)scheduler;

+ (nonnull RxObservable<NSNumber *> *)timer:(RxTimeInterval)dueTime
                                  scheduler:(nonnull id <RxSchedulerType>)scheduler;
@end

@interface RxObservable<E> (Take)
/**
 * Takes elements for the specified duration from the start of the observable source sequence, using the specified scheduler to run timers.
 * @see [take operator on reactivex.io](http://reactivex.io/documentation/operators/take.html)
 * @param duration: Duration for taking elements from the start of the sequence.
 * @param scheduler: Scheduler to run the timer on.
 * @return: An observable sequence with the elements taken during the specified duration from the start of the source sequence.
 */
- (nonnull RxObservable<E> *)take:(RxTimeInterval)duration scheduler:(nonnull id <RxSchedulerType>)scheduler;

@end

@interface RxObservable<E> (Skip)
/**
 * Skips elements for the specified duration from the start of the observable source sequence, using the specified scheduler to run timers.
 * @see [skip operator on reactivex.io](http://reactivex.io/documentation/operators/skip.html)
 * @param duration: Duration for skipping elements from the start of the sequence.
 * @param scheduler: Scheduler to run the timer on.
 * @return: An observable sequence with the elements skipped during the specified duration from the start of the source sequence.
 */
- (nonnull RxObservable<E> *)skip:(RxTimeInterval)duration scheduler:(nonnull id <RxSchedulerType>)scheduler;

@end

@interface RxObservable<E> (IgnoreElements)
/**
 * Skips elements and completes (or errors) when the receiver completes (or errors). Equivalent to filter that always returns false.
 * @see [ignoreElements operator on reactivex.io](http://reactivex.io/documentation/operators/ignoreelements.html)
 * @return: An observable sequence that skips all elements of the source sequence.
 */
- (nonnull RxObservable<E> *)ignoreElements;

@end

@interface RxObservable<E> (DelaySubscription)
/**
 * Time shifts the observable sequence by delaying the subscription with the specified relative time duration, using the specified scheduler to run timers.
 * @see [delay operator on reactivex.io](http://reactivex.io/documentation/operators/delay.html)
 * @param dueTime: Relative time shift of the subscription.
 * @param scheduler: Scheduler to run the subscription delay timer on.
 * @return: Time-shifted sequence.
 */
- (nonnull RxObservable<E> *)delaySubscription:(RxTimeInterval)dueTime scheduler:(nonnull id <RxSchedulerType>)scheduler;

@end

@interface RxObservable<E> (Buffer)
/**
 * Projects each element of an observable sequence into a buffer that's sent out when either it's full or a given amount of time has elapsed, using the specified scheduler to run timers.
 * A useful real-world analogy of this overload is the behavior of a ferry leaving the dock when all seats are taken, or at the scheduled time of departure, whichever event occurs first.
 * @see [buffer operator on reactivex.io](http://reactivex.io/documentation/operators/buffer.html)
 * @param timeSpan: Maximum time length of a buffer.
 * @param count: Maximum element count of a buffer.
 * @param scheduler: Scheduler to run buffering timers on.
 * @return: An observable sequence of buffers.
 */
- (nonnull RxObservable<NSArray<E> *> *)buffer:(RxTimeInterval)timeSpan
                                         count:(NSUInteger)count
                                     scheduler:(nonnull id <RxSchedulerType>)scheduler;

@end

@interface RxObservable<E> (Window)
/**
 * Projects each element of an observable sequence into a window that is completed when either it’s full or a given amount of time has elapsed.
 * @see [window operator on reactivex.io](http://reactivex.io/documentation/operators/window.html)
 * @param timeSpan: Maximum time length of a window.
 * @param count: Maximum element count of a window.
 * @param scheduler: Scheduler to run windowing timers on.
 * @return: An observable sequence of windows (instances of `Observable`).
 */
- (nonnull RxObservable<RxObservable<E> *> *)window:(RxTimeInterval)timeSpan
                                              count:(NSUInteger)count
                                          scheduler:(nonnull id <RxSchedulerType>)scheduler;

@end

@interface RxObservable<E> (Timeout)
/**
 * Applies a timeout policy for each element in the observable sequence.
 * If the next element isn't received within the specified timeout duration starting from its predecessor, a TimeoutError is propagated to the observer.
 * @see [timeout operator on reactivex.io](http://reactivex.io/documentation/operators/timeout.html)
 * @param dueTime: Maximum duration between values before a timeout occurs.
 * @param scheduler: Scheduler to run the timeout timer on.
 * @return: An observable sequence with a TimeoutError in case of a timeout.
 */
- (nonnull RxObservable<E> *)timeout:(RxTimeInterval)dueTime scheduler:(nonnull id <RxSchedulerType>)scheduler;

/**
 * Applies a timeout policy for each element in the observable sequence, using the specified scheduler to run timeout timers.
 * If the next element isn't received within the specified timeout duration starting from its predecessor, the other observable sequence is used to produce future messages from that point on.
 * @see [timeout operator on reactivex.io](http://reactivex.io/documentation/operators/timeout.html)
 * @param dueTime: Maximum duration between values before a timeout occurs.
 * @param other: Sequence to return in case of a timeout.
 * @param scheduler: Scheduler to run the timeout timer on.
 * @return: The source sequence switching to the other sequence in case of a timeout.
 */
- (nonnull RxObservable<E> *)timeout:(RxTimeInterval)dueTime
                               other:(nonnull id <RxObservableConvertibleType>)other
                           scheduler:(nonnull id <RxSchedulerType>)scheduler;

@end

NS_ASSUME_NONNULL_END