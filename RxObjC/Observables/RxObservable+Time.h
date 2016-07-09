//
//  RxObservable(Time)
//  RxObjC
// 
//  Created by Pavel Malkov on 04.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservable.h"
#import "RxSchedulerType.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (RxThrottle) <RxObservableType>
/**
Ignores elements from an observable sequence which are followed by another element within a specified relative time duration, using the specified scheduler to run throttling timers.

`throttle` and `debounce` are synonyms.

- seealso: [debounce operator on reactivex.io](http://reactivex.io/documentation/operators/debounce.html)

- parameter dueTime: Throttling duration for each element.
- parameter scheduler: Scheduler to run the throttle timers and send events on.
- returns: The throttled sequence.
*/
- (nonnull RxObservable *)throttle:(RxTimeInterval)dueTime scheduler:(nonnull id <RxSchedulerType>)scheduler;

/**
Ignores elements from an observable sequence which are followed by another element within a specified relative time duration, using the specified scheduler to run throttling timers.

`throttle` and `debounce` are synonyms.

- seealso: [debounce operator on reactivex.io](http://reactivex.io/documentation/operators/debounce.html)

- parameter dueTime: Throttling duration for each element.
- parameter scheduler: Scheduler to run the throttle timers and send events on.
- returns: The throttled sequence.
*/
- (nonnull RxObservable *)debounce:(RxTimeInterval)dueTime scheduler:(nonnull id <RxSchedulerType>)scheduler;

@end

@interface NSObject (RxSample) <RxObservableType>
/**
Samples the source observable sequence using a samper observable sequence producing sampling ticks.

Upon each sampling tick, the latest element (if any) in the source sequence during the last sampling interval is sent to the resulting sequence.

**In case there were no new elements between sampler ticks, no element is sent to the resulting sequence.**

- seealso: [sample operator on reactivex.io](http://reactivex.io/documentation/operators/sample.html)

- parameter sampler: Sampling tick sequence.
- returns: Sampled observable sequence.
*/
- (nonnull RxObservable *)sample:(nonnull id <RxObservableType>)sampler;
@end

@interface RxObservable (Interval)
/**
Returns an observable sequence that produces a value after each period, using the specified scheduler to run timers and to send out observer messages.

- seealso: [interval operator on reactivex.io](http://reactivex.io/documentation/operators/interval.html)

- parameter period: Period for producing the values in the resulting sequence.
- parameter scheduler: Scheduler to run the timer on.
- returns: An observable sequence that produces a value after each period.
*/
- (nonnull RxObservable<NSNumber *> *)interval:(RxTimeInterval)period
                                     scheduler:(nonnull id <RxSchedulerType>)scheduler;
@end

@interface RxObservable (Timer)
/**
Returns an observable sequence that periodically produces a value after the specified initial relative due time has elapsed, using the specified scheduler to run timers.

- seealso: [timer operator on reactivex.io](http://reactivex.io/documentation/operators/timer.html)

- parameter dueTime: Relative time at which to produce the first value.
- parameter period: Period to produce subsequent values.
- parameter scheduler: Scheduler to run timers on.
- returns: An observable sequence that produces a value after due time has elapsed and then each period.
*/
- (nonnull RxObservable<NSNumber *> *)timer:(RxTimeInterval)dueTime
                                     period:(RxTimeInterval)period
                                  scheduler:(nonnull id <RxSchedulerType>)scheduler;

- (nonnull RxObservable<NSNumber *> *)timer:(RxTimeInterval)dueTime
                                  scheduler:(nonnull id <RxSchedulerType>)scheduler;
@end

@interface NSObject (RxTake) <RxObservableType>
/**
Takes elements for the specified duration from the start of the observable source sequence, using the specified scheduler to run timers.

- seealso: [take operator on reactivex.io](http://reactivex.io/documentation/operators/take.html)

- parameter duration: Duration for taking elements from the start of the sequence.
- parameter scheduler: Scheduler to run the timer on.
- returns: An observable sequence with the elements taken during the specified duration from the start of the source sequence.
*/
- (nonnull RxObservable *)take:(RxTimeInterval)duration scheduler:(nonnull id <RxSchedulerType>)scheduler;
@end

@interface NSObject (RxSkip) <RxObservableType>
/**
Skips elements for the specified duration from the start of the observable source sequence, using the specified scheduler to run timers.

- seealso: [skip operator on reactivex.io](http://reactivex.io/documentation/operators/skip.html)

- parameter duration: Duration for skipping elements from the start of the sequence.
- parameter scheduler: Scheduler to run the timer on.
- returns: An observable sequence with the elements skipped during the specified duration from the start of the source sequence.
*/
- (nonnull RxObservable *)skip:(RxTimeInterval)duration scheduler:(nonnull id <RxSchedulerType>)scheduler;
@end

@interface NSObject (RxIgnoreElements) <RxObservableType>
/**
 Skips elements and completes (or errors) when the receiver completes (or errors). Equivalent to filter that always returns false.

 - seealso: [ignoreElements operator on reactivex.io](http://reactivex.io/documentation/operators/ignoreelements.html)

 - returns: An observable sequence that skips all elements of the source sequence.
 */
- (nonnull RxObservable *)ignoreElements;
@end

@interface NSObject (RxDelaySubscription) <RxObservableType>
/**
Time shifts the observable sequence by delaying the subscription with the specified relative time duration, using the specified scheduler to run timers.

- seealso: [delay operator on reactivex.io](http://reactivex.io/documentation/operators/delay.html)

- parameter dueTime: Relative time shift of the subscription.
- parameter scheduler: Scheduler to run the subscription delay timer on.
- returns: Time-shifted sequence.
*/
- (nonnull RxObservable *)delaySubscription:(RxTimeInterval)dueTime scheduler:(nonnull id <RxSchedulerType>)scheduler;

@end

@interface NSObject (RxBuffer) <RxObservableType>
/**
Projects each element of an observable sequence into a buffer that's sent out when either it's full or a given amount of time has elapsed, using the specified scheduler to run timers.

A useful real-world analogy of this overload is the behavior of a ferry leaving the dock when all seats are taken, or at the scheduled time of departure, whichever event occurs first.

- seealso: [buffer operator on reactivex.io](http://reactivex.io/documentation/operators/buffer.html)

- parameter timeSpan: Maximum time length of a buffer.
- parameter count: Maximum element count of a buffer.
- parameter scheduler: Scheduler to run buffering timers on.
- returns: An observable sequence of buffers.

*/
- (nonnull RxObservable<NSArray<id> *> *)buffer:(RxTimeInterval)timeSpan
                                          count:(NSUInteger)count
                                      scheduler:(nonnull id <RxSchedulerType>)scheduler;

@end

@interface NSObject (RxWindow) <RxObservableType>
/**
 Projects each element of an observable sequence into a window that is completed when either it’s full or a given amount of time has elapsed.

 - seealso: [window operator on reactivex.io](http://reactivex.io/documentation/operators/window.html)

 - parameter timeSpan: Maximum time length of a window.
 - parameter count: Maximum element count of a window.
 - parameter scheduler: Scheduler to run windowing timers on.
 - returns: An observable sequence of windows (instances of `Observable`).
 */
- (nonnull RxObservable<RxObservable *> *)window:(RxTimeInterval)timeSpan
                                           count:(NSUInteger)count
                                       scheduler:(nonnull id <RxSchedulerType>)scheduler;

@end

@interface NSObject (RxTimeout) <RxObservableType>
/**
 Applies a timeout policy for each element in the observable sequence. If the next element isn't received within the specified timeout duration starting from its predecessor, a TimeoutError is propagated to the observer.

 - seealso: [timeout operator on reactivex.io](http://reactivex.io/documentation/operators/timeout.html)

 - parameter dueTime: Maximum duration between values before a timeout occurs.
 - parameter scheduler: Scheduler to run the timeout timer on.
 - returns: An observable sequence with a TimeoutError in case of a timeout.
 */
- (nonnull RxObservable *)timeout:(RxTimeInterval)dueTime scheduler:(nonnull id <RxSchedulerType>)scheduler;

/**
 Applies a timeout policy for each element in the observable sequence, using the specified scheduler to run timeout timers. If the next element isn't received within the specified timeout duration starting from its predecessor, the other observable sequence is used to produce future messages from that point on.

 - seealso: [timeout operator on reactivex.io](http://reactivex.io/documentation/operators/timeout.html)

 - parameter dueTime: Maximum duration between values before a timeout occurs.
 - parameter other: Sequence to return in case of a timeout.
 - parameter scheduler: Scheduler to run the timeout timer on.
 - returns: The source sequence switching to the other sequence in case of a timeout.
 */
- (nonnull RxObservable *)timeout:(RxTimeInterval)dueTime
                            other:(nonnull id <RxObservableConvertibleType>)other
                        scheduler:(nonnull id <RxSchedulerType>)scheduler;

@end

NS_ASSUME_NONNULL_END