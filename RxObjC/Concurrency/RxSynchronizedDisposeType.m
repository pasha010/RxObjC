//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSynchronizedDisposeType.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation NSObject (RxSynchronizedDisposeType)

- (void)synchronizedDispose {
    [self _lock];
    [self _synchronized_dispose];
    [self _unlock];
}

@end
#pragma clang diagnostic pop