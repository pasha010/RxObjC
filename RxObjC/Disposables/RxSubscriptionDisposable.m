//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSubscriptionDisposable.h"
#import "RxSynchronizedUnsubscribeType.h"


@implementation RxSubscriptionDisposable {
    __weak id <RxSynchronizedUnsubscribeType> __nonnull _owner;
    __strong id __nonnull _key;
}

- (nonnull instancetype)initWithOwner:(nonnull __weak id <RxSynchronizedUnsubscribeType>)owner andKey:(nonnull id)key {
    self = [super init];
    if (self) {
        _owner = owner;
        _key = key;
    }
    return self;
}

- (void)dispose {
    [_owner synchronizedUnsubscribe:_key];
}


@end