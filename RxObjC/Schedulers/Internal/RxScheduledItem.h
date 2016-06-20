//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxScheduledItemType.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxScheduledItem<T> : NSObject <RxScheduledItemType, RxInvocableType>

- (nonnull instancetype)initWithAction:(nonnull id <RxDisposable>(^)(id))action andState:(nonnull T)state;

- (void)invoke;

- (BOOL)disposed;

- (void)dispose;
@end

NS_ASSUME_NONNULL_END