//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RxLock <NSObject>
@required
- (void)rx_lock;
- (void)rx_unlock;
@end

#define RxSpinLock NSRecursiveLock

@interface NSRecursiveLock (RxAdditions)

- (void)performLock:(void(^)())action;

- (nullable id)calculateLocked:(id(^)())action;

@end

NS_ASSUME_NONNULL_END