//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxCurrentThreadScheduler.h"
#import "RxScheduledItemType.h"
#import "NSThread+RxLocalStorageValue.h"
#import "RxAnonymousDisposable.h"
#import "RxScheduledItem.h"

RxCurrentThreadSchedulerKey *rx_getCurrentThreadSchedulerKeyInstance() {
    static dispatch_once_t token;
    static RxCurrentThreadSchedulerKey *CurrentThreadSchedulerKeyInstance;
    dispatch_once(&token, ^{
        CurrentThreadSchedulerKeyInstance = [[RxCurrentThreadSchedulerKey alloc] init];
    });
    return CurrentThreadSchedulerKeyInstance;
}

RxCurrentThreadSchedulerKey *rx_getCurrentThreadSchedulerValueInstance() {
    static dispatch_once_t token;
    static RxCurrentThreadSchedulerKey *CurrentThreadSchedulerValueInstance;
    dispatch_once(&token, ^{
        CurrentThreadSchedulerValueInstance = rx_getCurrentThreadSchedulerKeyInstance();
    });
    return CurrentThreadSchedulerValueInstance;
}

@implementation RxCurrentThreadSchedulerKey

- (BOOL)isEqual:(id)other {
    return other == rx_getCurrentThreadSchedulerKeyInstance();
}

- (NSUInteger)hash {
    return (NSUInteger) -904739208;
}

- (id)copyWithZone:(NSZone *)zone {
    return rx_getCurrentThreadSchedulerKeyInstance();
}

@end

RxCurrentThreadSchedulerQueueKey *rx_getCurrentThreadSchedulerQueueKeyInstance() {
    static dispatch_once_t token;
    static RxCurrentThreadSchedulerQueueKey *CurrentThreadSchedulerQueueKeyInstance;
    dispatch_once(&token, ^{
        CurrentThreadSchedulerQueueKeyInstance = [[RxCurrentThreadSchedulerQueueKey alloc] init];
    });
    return CurrentThreadSchedulerQueueKeyInstance;
}

@implementation RxCurrentThreadSchedulerQueueKey

- (BOOL)isEqual:(id)other {
    return other == rx_getCurrentThreadSchedulerQueueKeyInstance();
}

- (NSUInteger)hash {
    return (NSUInteger) -904739207;
}

- (id)copyWithZone:(NSZone *)zone {
    return rx_getCurrentThreadSchedulerQueueKeyInstance();
}

@end

@interface RxCurrentThreadScheduler ()
@property (assign, readwrite) BOOL isScheduleRequired;
@end

@implementation RxCurrentThreadScheduler

+ (nonnull instancetype)sharedInstance {
    static dispatch_once_t token;
    static RxCurrentThreadScheduler *instance;
    dispatch_once(&token, ^{
        rx_getCurrentThreadSchedulerKeyInstance();
        rx_getCurrentThreadSchedulerValueInstance();
        rx_getCurrentThreadSchedulerQueueKeyInstance();
        instance = [[RxCurrentThreadScheduler alloc] init];
    });
    return instance;
}

- (nullable RxMutableBox<RxQueue<id <RxScheduledItemType>> *> *)queue {
    return [NSThread rx_getThreadLocalStorageValueForKey:rx_getCurrentThreadSchedulerQueueKeyInstance()];
}

- (void)setQueue:(nullable RxMutableBox<RxQueue<id <RxScheduledItemType>> *> *)queue {
    [NSThread rx_setThreadLocalStorageValue:queue forKey:rx_getCurrentThreadSchedulerQueueKeyInstance()];
}

- (BOOL)isScheduleRequired {
    RxCurrentThreadSchedulerKey *value = [NSThread rx_getThreadLocalStorageValueForKey:rx_getCurrentThreadSchedulerKeyInstance()];
    return value == nil;
}

- (void)setIsScheduleRequired:(BOOL)isScheduleRequired {
    id value = isScheduleRequired ? nil : rx_getCurrentThreadSchedulerValueInstance();
    [NSThread rx_setThreadLocalStorageValue:value forKey:rx_getCurrentThreadSchedulerKeyInstance()];
}

- (nonnull id <RxDisposable>)schedule:(nullable RxStateType)state action:(id <RxDisposable> (^)(RxStateType))action {
    if (self.isScheduleRequired) {
        self.isScheduleRequired = NO;

        id <RxDisposable> disposable = action(state);
        
        if (self.queue == nil) {
            self.isScheduleRequired = YES;
            self.queue = nil;
            return disposable;
        }
        id <RxScheduledItemType> latest = [self.queue.value dequeue];
        while (latest) {
            if (![latest disposed]) {
                [latest invoke];
            }
            latest = [self.queue.value dequeue];
        }

        self.isScheduleRequired = YES;
        self.queue = nil;
        
        return disposable;
    }

    RxMutableBox<RxQueue<id <RxScheduledItemType>> *> *existingQueue = self.queue;

    RxMutableBox<RxQueue<id <RxScheduledItemType>> *> *queue;
    if (existingQueue) {
        queue = existingQueue;
    } else {
        queue = [[RxMutableBox alloc] initWithValue:[[RxQueue alloc] initWithCapacity:1]];
        self.queue = queue;
    }

    RxScheduledItem *scheduledItem = [[RxScheduledItem alloc] initWithAction:action andState:state];
    [queue.value enqueue:scheduledItem];

    // In Xcode 7.3, `return scheduledItem` causes segmentation fault 11 on release build.
    // To workaround this compiler issue, returns AnonymousDisposable that disposes scheduledItem.
    return [[RxAnonymousDisposable alloc] initWithDisposeAction:^{
        [scheduledItem dispose];
    }];
}

@end