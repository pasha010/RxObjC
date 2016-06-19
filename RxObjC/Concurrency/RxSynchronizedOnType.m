//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSynchronizedOnType.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation NSObject (RxSynchronizedOnType)

- (void)synchronizedOn:(RxEvent *)event {
    [self lock];
    [self _synchronized_on:event];
    [self unlock];
}


@end
#pragma clang diagnostic pop