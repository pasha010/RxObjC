//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RxImmediateSchedulerType;

NS_ASSUME_NONNULL_BEGIN

typedef void (^RxRecursiveImmediateAction)(id, void(^)(id));

/**
Type erased recursive scheduler.
*/
@interface RxRecursiveImmediateScheduler<__covariant State> : NSObject

- (nonnull instancetype)initWithActon:(RxRecursiveImmediateAction)action andScheduler:(nonnull id <RxImmediateSchedulerType>)scheduler;

/**
Schedules an action to be executed recursively.

- parameter state: State passed to the action to be executed.
*/
- (void)schedule:(nonnull State)state;

- (void)dispose;
@end

NS_ASSUME_NONNULL_END