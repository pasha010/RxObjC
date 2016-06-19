//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "NSRecursiveLock+RxAdditions.h"


@implementation NSRecursiveLock (RxAdditions)

- (void)performLock:(void (^)())action {
    [self lock];
    if (action) {
        action();
    }
    [self unlock];
}

- (nullable id)calculateLocked:(id(^)())action {
    [self lock];
    id result;
    if (action) {
        result = action();
    }
    [self unlock];
    return result;
}

@end