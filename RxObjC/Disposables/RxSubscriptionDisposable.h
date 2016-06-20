//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxDisposable.h"

@protocol RxSynchronizedUnsubscribeType;

NS_ASSUME_NONNULL_BEGIN

@interface RxSubscriptionDisposable<__covariant T : id <RxSynchronizedUnsubscribeType>, K> : NSObject <RxDisposable>

- (nonnull instancetype)initWithOwner:(nonnull T)owner andKey:(nonnull K)key;

@end

NS_ASSUME_NONNULL_END