//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxVirtualTimeScheduler.h"
#import "RxTestSchedulerVirtualTimeConverter.h"

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

/**
 Creates a new test scheduler.

 - parameter initialClock: Initial value for the clock.
 - parameter resolution: Real time [NSTimeInterval] = ticks * resolution
 - parameter simulateProcessingDelay: When true, if something is scheduled right `now`,
    it will be scheduled to `now + 1` in virtual time.
*/
- (nonnull instancetype)initWithInitialClock:(NSUInteger)initialClock
                                  resolution:(double)resolution
                     simulateProcessingDelay:(BOOL)simulateProcessingDelay;

/**
Creates a hot observable using the specified timestamped events.

- parameter events: Events to surface through the created sequence at their specified absolute virtual times.
- returns: Hot observable sequence that can be used to assert the timing of subscriptions and events.
*/
- (RxTestableObservable<id> *)createHotObservable:(NSArray<RxRecorder<id> *> *)events;

@end

NS_ASSUME_NONNULL_END