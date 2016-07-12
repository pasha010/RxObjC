//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSynchronizedOnType.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma GCC diagnostic ignored "-Wprotocol"
@implementation NSObject (RxSynchronizedOnType)

- (void)synchronizedOn:(nonnull RxEvent *)event {
    [self _lock];
    [self _synchronized_on:event];
    [self _unlock];
}


@end
#pragma clang diagnostic pop