//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTestScheduler.h"
#import "RxTestableObservable.h"
#import "RxHotObservable.h"
#import "RxNopDisposable.h"
#import "RxColdObservable.h"
#import "RxTestableObserver.h"
#import "RxObservable.h"
#import "RxDisposable.h"

@implementation RxTestScheduler {
    BOOL _simulateProcessingDelay;
}

- (nonnull instancetype)initWithInitialClock:(RxTestTime)initialClock {
    return [self initWithInitialClock:initialClock resolution:1.0 simulateProcessingDelay:YES];
}

- (nonnull instancetype)initWithInitialClock:(RxTestTime)initialClock
                                  resolution:(double)resolution
                     simulateProcessingDelay:(BOOL)simulateProcessingDelay {
    self = [super initWithInitialClock:@(initialClock) andConverter:[[RxTestSchedulerVirtualTimeConverter alloc] initWithResolution:resolution]];
    if (self) {
        _simulateProcessingDelay = simulateProcessingDelay;
    }
    return self;
}

- (nonnull RxTestableObservable<id> *)createHotObservable:(nonnull NSArray<RxRecorded<RxEvent<id> *> *> *)events {
    return [[RxHotObservable alloc] initWithTestScheduler:self recordedEvents:events];
}

- (nonnull RxTestableObservable<id> *)createColdObservable:(nonnull NSArray<RxRecorded<RxEvent<id> *> *> *)events {
    return [[RxColdObservable alloc] initWithTestScheduler:self recordedEvents:events];
}

- (nonnull RxTestableObserver<id> *)createObserver {
    return [[RxTestableObserver alloc] initWithTestScheduler:self];
}

- (void)scheduleAt:(RxTestTime)time action:(void(^)())action {
    [self scheduleAbsoluteVirtual:nil time:@(time) action:^id <RxDisposable>(id o) {
        action();
        return [RxNopDisposable sharedInstance];
    }];
}

- (nonnull NSNumber *)adjustScheduledTime:(nonnull NSNumber *)time {
    NSUInteger clock = self.clock.unsignedIntegerValue;
    return time.unsignedIntegerValue <= clock ? @(clock + (_simulateProcessingDelay ? 1 : 0)) : time;
}

- (nonnull RxTestableObserver *)start:(RxTestTime)created
                           subscribed:(RxTestTime)subscribed
                             disposed:(RxTestTime)disposed
                               create:(RxObservable *(^)())create {
    __block RxObservable *source = nil;
    __block id <RxDisposable> subscription = nil;
    __block RxTestableObserver *observer = [self createObserver];

    [self scheduleAbsoluteVirtual:nil time:@(created) action:^id <RxDisposable>(id o) {
        source = create();
        return [RxNopDisposable sharedInstance];
    }];
    
    [self scheduleAbsoluteVirtual:nil time:@(subscribed) action:^id <RxDisposable>(id o) {
        subscription = [source subscribe:observer];
        return [RxNopDisposable sharedInstance];
    }];

    [self scheduleAbsoluteVirtual:nil time:@(disposed) action:^id <RxDisposable>(id o) {
        [subscription dispose];
        return [RxNopDisposable sharedInstance];
    }];

    [self start];

    return observer;
}

- (nonnull RxTestableObserver *)startWhenDisposed:(RxTestTime)disposed create:(RxObservable *(^)())create {
    return [self start:RxTestSchedulerDefaultCreated subscribed:RxTestSchedulerDefaultSubscribed disposed:disposed create:create];
}

- (nonnull RxTestableObserver *)start:(RxObservable *(^)())create {
    return [self startWhenDisposed:RxTestSchedulerDefaultDisposed create:create];
}

@end