//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxImmediateSchedulerType.h"
#import "RxAnonymousDisposable.h"
#import "RxRecursiveScheduler.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation NSObject (RxImmediateSchedulerType)

- (nonnull id <RxDisposable>)scheduleRecursive:(nonnull id)state action:(RxRecursiveImmediateAction)action {
    RxRecursiveImmediateScheduler *recursiveScheduler = [[RxRecursiveImmediateScheduler alloc] initWithActon:action andScheduler:self];

    [recursiveScheduler schedule:state];

    return [[RxAnonymousDisposable alloc] initWithDisposeAction:^{[recursiveScheduler dispose];}];
}

@end
#pragma clang diagnostic pop