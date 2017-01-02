//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSynchronizedSubscribeType.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma GCC diagnostic ignored "-Wprotocol"
@implementation NSObject (RxSynchronizedSubscribeType)

- (nonnull id <RxDisposable>)synchronizedSubscribe:(nonnull id <RxObserverType>)observer {
    [self rx_lock];
    id <RxDisposable> disposable = [self _synchronized_subscribe:observer];
    [self rx_unlock];
    return disposable;
}

@end
#pragma clang diagnostic pop