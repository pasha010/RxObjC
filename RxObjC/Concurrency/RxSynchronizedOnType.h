//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObserverType.h"
#import "RxLock.h"

@class RxEvent<E>;

NS_ASSUME_NONNULL_BEGIN

@protocol RxSynchronizedOnType <RxObserverType, RxLock>
- (void)_synchronized_on:(nonnull RxEvent<id> *)event;
@end

FOUNDATION_EXTERN void rx_synchronizedOn(id <RxSynchronizedOnType> _Nonnull locker, RxEvent<id> *_Nonnull event);



NS_ASSUME_NONNULL_END