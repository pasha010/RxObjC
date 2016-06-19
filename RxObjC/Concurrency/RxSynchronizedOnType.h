//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxEvent.h"
#import "RxObserverType.h"
#import "RxLock.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RxSynchronizedOnType <RxObserverType, RxLock>
- (void)_synchronized_on:(nonnull RxEvent<id> *)event;
@end

@interface NSObject (RxSynchronizedOnType) <RxSynchronizedOnType>
- (void)synchronizedOn:(nonnull RxEvent<id> *)event;
@end

NS_ASSUME_NONNULL_END