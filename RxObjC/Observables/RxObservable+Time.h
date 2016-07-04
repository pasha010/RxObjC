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

NS_ASSUME_NONNULL_END