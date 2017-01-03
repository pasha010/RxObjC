//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxAsyncLock.h"
#import "RxInvocableType.h"
#import "RxQueue.h"


@implementation RxAsyncLock {
    RxSpinLock *__nonnull _lock;
    RxQueue<id <RxInvocableType>> *__nonnull _queue;
    BOOL _isExecuting;
    BOOL _hasFaulted;
}

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _lock = [[RxSpinLock alloc] init];
        _queue = [[RxQueue alloc] initWithCapacity:0];
        _isExecuting = NO;
        _hasFaulted = NO;
    }
    return self;
}

- (void)rx_lock {
    [_lock lock];
}

- (void)rx_unlock {
    [_lock unlock];
}

- (nullable id <RxInvocableType>)enqueue:(nonnull id <RxInvocableType>)action {
    return [_lock calculateLocked:^id <RxInvocableType> {
        if (_hasFaulted) {
            return nil;
        }

        if (_isExecuting) {
            [_queue enqueue:action];
            return nil;
        }

        _isExecuting = YES;
        
        return action;
    }];
}

- (nullable id <RxInvocableType>)dequeue {
    return [_lock calculateLocked:^id <RxInvocableType> {
        if (_queue.count > 0) {
            return [_queue dequeue];
        } else {
            _isExecuting = NO;
        }
        return nil;
    }];
}

- (void)invoke:(nonnull id <RxInvocableType>)action {
    id <RxInvocableType> firstEnqueuedAction = [self enqueue:action];
    
    if (firstEnqueuedAction) {
        [firstEnqueuedAction invoke];
    } else {
        // action is enqueued, it's somebody else's concern now
        return;
    }
    
    while (YES) {
        id <RxInvocableType> nextAction = [self dequeue];
        if (nextAction) {
            [nextAction invoke];
        } else {
            return;
        }
    }
}

- (void)dispose {
    [self rx_lock];
    [self _synchronized_dispose];
    [self rx_unlock];
}

- (void)_synchronized_dispose {
    _queue = [[RxQueue alloc] initWithCapacity:0];
    _hasFaulted = YES;
}

@end