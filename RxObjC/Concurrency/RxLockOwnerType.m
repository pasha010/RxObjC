//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxLockOwnerType.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma GCC diagnostic ignored "-Wprotocol"
@implementation NSObject (RxLockOwnerType)

- (void)_lock {
    [[self lock] lock];
}

- (void)_unlock {
    [[self lock] unlock];
}


@end

#pragma clang diagnostic pop