//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxVirtualTimeScheduler.h"
#import "RxTestSchedulerVirtualTimeConverter.h"
#import "RxEvent.h"
#import "RxRecorded.h"
#import "RxTestsDefTypes.h"

@class RxTestableObserver;
@class RxTestableObservable;
@class RxObservable;

NS_ASSUME_NONNULL_BEGIN

/**
 Default absolute time when to create tested observable sequence.
*/
static NSUInteger const RxTestSchedulerDefaultCreated = 100;

/**
Default absolute time when to subscribe to tested observable sequence.
*/
static NSUInteger const RxTestSchedulerDefaultSubscribed = 200;

/**
 Default absolute time when to dispose subscription to tested observable sequence.
*/
static NSUInteger const RxTestSchedulerDefaultDisposed = 1000;

/**
Virtual time scheduler used for testing applications and libraries built using RxSwift.
*/
@interface RxTestScheduler : RxVirtualTimeScheduler<RxTestSchedulerVirtualTimeConverter *>

- (nonnull instancetype)initWithInitialClock:(RxTestTime)initialClock;

/**
 Creates a new test scheduler.

 - parameter initialClock: Initial value for the clock.
 - parameter resolution: Real time [NSTimeInterval] = ticks * resolution
 - parameter simulateProcessingDelay: When true, if something is scheduled right `now`,
    it will be scheduled to `now + 1` in virtual time.
*/
- (nonnull instancetype)initWithInitialClock:(RxTestTime)initialClock
                                  resolution:(double)resolution
                     simulateProcessingDelay:(BOOL)simulateProcessingDelay;

/**
Creates a hot observable using the specified timestamped events.

- parameter events: Events to surface through the created sequence at their specified absolute virtual times.
- returns: Hot observable sequence that can be used to assert the timing of subscriptions and events.
*/
- (nonnull RxTestableObservable *)createHotObservable:(nonnull NSArray<RxRecorded<RxEvent<id> *> *> *)events;

/**
Creates a cold observable using the specified timestamped events.

 - parameter events: Events to surface through the created sequence at their specified virtual time offsets from the sequence subscription time.
 - returns: Cold observable sequence that can be used to assert the timing of subscriptions and events.
*/
- (nonnull RxTestableObservable *)createColdObservable:(nonnull NSArray<RxRecorded<RxEvent<id> *> *> *)events;

/**
Creates an observer that records received events and timestamps those.

 - parameter type: Optional type hint of the observed sequence elements.
 - returns: Observer that can be used to assert the timing of events.
*/
- (nonnull RxTestableObserver *)createObserver;
/**
 Schedules an action to be executed at the specified virtual time.

 - parameter time: Absolute virtual time at which to execute the action.
 */
- (void)scheduleAt:(RxTestTime)time action:(void(^)())action;

/**
Adjusts time of scheduling before adding item to schedule queue. If scheduled time is `<= clock`, then it is scheduled at `clock + 1`
*/
- (nonnull RxVirtualTimeUnit)adjustScheduledTime:(nonnull RxVirtualTimeUnit)time;

/**
Starts the test scheduler and uses the specified virtual times to invoke the factory function, subscribe to the resulting sequence, and dispose the subscription.

- parameter create: Factory method to create an observable sequence.
- parameter created: Virtual time at which to invoke the factory to create an observable sequence.
- parameter subscribed: Virtual time at which to subscribe to the created observable sequence.
- parameter disposed: Virtual time at which to dispose the subscription.
- returns: Observer with timestamped recordings of events that were received during the virtual time window when the subscription to the source sequence was active.
*/
- (nonnull RxTestableObserver *)start:(RxTestTime)created
                           subscribed:(RxTestTime)subscribed
                             disposed:(RxTestTime)disposed
                               create:(RxObservable *(^)())create;

/**
 Starts the test scheduler and uses the specified virtual times to invoke the factory function, subscribe to the resulting sequence, and dispose the subscription.

 Observable sequence will be:
 * created at virtual time `Defaults.created`           -> 100
 * subscribed to at virtual time `Defaults.subscribed`  -> 200

 - parameter create: Factory method to create an observable sequence.
 - parameter disposed: Virtual time at which to dispose the subscription.
 - returns: Observer with timestamped recordings of events that were received during the virtual time window when the subscription to the source sequence was active.
 */
- (nonnull RxTestableObserver *)start:(RxTestTime)disposed create:(RxObservable *(^)())create;

/**
 Starts the test scheduler and uses the specified virtual times to invoke the factory function, subscribe to the resulting sequence, and dispose the subscription.

 Observable sequence will be:
 * created at virtual time `Defaults.created`           -> 100
 * subscribed to at virtual time `Defaults.subscribed`  -> 200
 * subscription will be disposed at `Defaults.disposed` -> 1000

 - parameter create: Factory method to create an observable sequence.
 - returns: Observer with timestamped recordings of events that were received during the virtual time window when the subscription to the source sequence was active.
 */
- (nonnull RxTestableObserver *)start:(RxObservable *(^)())create;

@end

NS_ASSUME_NONNULL_END