//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSynchronizedOnType.h"

void rx_synchronizedOn(id <RxSynchronizedOnType> _Nonnull locker, RxEvent<id> *_Nonnull event) {
    [locker rx_lock];
    [locker _synchronized_on:event];
    [locker rx_unlock];
}