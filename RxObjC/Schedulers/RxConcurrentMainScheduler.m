//
//  RxConcurrentMainScheduler
//  RxObjC
// 
//  Created by Pavel Malkov on 14.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxConcurrentMainScheduler.h"
#import "RxMainScheduler.h"
#import "RxSingleAssignmentDisposable.h"


@implementation RxConcurrentMainScheduler {
    dispatch_queue_t _mainQueue;
    __weak RxMainScheduler *__nonnull _mainScheduler;
}

- (nonnull instancetype)initWithMainScheduler:(nonnull RxMainScheduler *)scheduler {
    self = [super init];
    if (self) {
        _mainQueue = dispatch_get_main_queue();
        _mainScheduler = scheduler;
    }
    return self;
}

+ (nonnull instancetype)instance {
    static RxConcurrentMainScheduler *_instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        _instance = [[self alloc] initWithMainScheduler:[RxMainScheduler sharedInstance]];
    });
    return _instance;
}

- (nonnull NSDate *)now {
    return [NSDate date];
}

- (nonnull id <RxDisposable>)schedule:(nullable RxStateType)state action:(nonnull id <RxDisposable> (^)(RxStateType __nullable))action {
    if ([NSThread currentThread].isMainThread) {
        return action(state);
    }

    RxSingleAssignmentDisposable *cancel = [[RxSingleAssignmentDisposable alloc] init];

    dispatch_async(_mainQueue, ^{
        if (cancel.disposed) {
            return;
        }

        cancel.disposable = action(state);
    });

    return cancel;
}

- (nonnull id <RxDisposable>)scheduleRelative:(nullable id)state dueTime:(RxTimeInterval)dueTime action:(id <RxDisposable>(^)(id))action {
    return [_mainScheduler scheduleRelative:state dueTime:dueTime action:action];
}

- (nonnull id <RxDisposable>)schedulePeriodic:(nullable id)state
                                   startAfter:(RxTimeInterval)startAfter
                                       period:(RxTimeInterval)period
                                       action:(id(^)(id __nullable ))action {
    return [_mainScheduler schedulePeriodic:state startAfter:startAfter period:period action:action];
}

@end