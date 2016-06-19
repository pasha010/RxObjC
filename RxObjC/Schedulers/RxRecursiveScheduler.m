//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxRecursiveScheduler.h"
#import "RxCompositeDisposable.h"
#import "RxImmediateSchedulerType.h"
#import "RxNopDisposable.h"
#import "NSRecursiveLock+RxAdditions.h"

@implementation RxRecursiveImmediateScheduler {
    NSRecursiveLock *__nonnull _lock;
    RxCompositeDisposable *__nonnull _group;
    RxRecursiveImmediateAction _action;
    id <RxImmediateSchedulerType> __nonnull _scheduler;
}

- (nonnull instancetype)initWithActon:(RxRecursiveImmediateAction)action andScheduler:(nonnull id <RxImmediateSchedulerType>)scheduler {
    self = [super init];
    if (self) {
        _lock = [[NSRecursiveLock alloc] init];
        _group = [[RxCompositeDisposable alloc] init];
        _action = action;
        _scheduler = scheduler;
    }
    return self;
}

- (void)schedule:(nonnull id)state {
    __block BOOL isAdded = NO;
    __block BOOL isDone = NO;

    __block RxBagKey *removeKey = nil;

    @weakify(self);
    id <RxDisposable> d = [_scheduler schedule:state action:^id <RxDisposable>(RxStateType s) {
        @strongify(self);
        if (!self) {
            return [RxNopDisposable sharedInstance];
        }

        // best effort
        if ([self->_group disposed]) {
            return [RxNopDisposable sharedInstance];
        }

        RxRecursiveImmediateAction action = [self->_lock calculateLocked:(id (^)()) ^RxRecursiveImmediateAction {
            if (isAdded) {
                [self->_group removeDisposable:removeKey];
            } else {
                isDone = YES;
            }
            return self->_action;
        }];

        if (action) {
            action(state, ^(id r) {
                [self schedule:r];
            });
        }

        return [RxNopDisposable sharedInstance];
    }];

    [_lock performLock:^{
        if (!isDone) {
            removeKey = [_group addDisposable:d];
            isAdded = YES;
        }
    }];


}

- (void)dispose {
    [_lock performLock:^{
        _action = nil;
    }];
    [_group dispose];
}

@end