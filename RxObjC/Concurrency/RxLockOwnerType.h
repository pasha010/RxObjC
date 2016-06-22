//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxLock.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RxLockOwnerType <RxLock>
- (nonnull RxSpinLock *)lock;
@end

@interface NSObject (RxLockOwnerType) <RxLockOwnerType>
@end

NS_ASSUME_NONNULL_END