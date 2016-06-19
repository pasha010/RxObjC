//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxLock.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RxLockOwnerType <NSObject>
- (nonnull RxSpinLock *)lock;
@end

NS_ASSUME_NONNULL_END