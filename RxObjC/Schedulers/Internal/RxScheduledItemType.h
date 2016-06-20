//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxCancelable.h"
#import "RxInvocableType.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RxScheduledItemType <RxCancelable, RxInvocableType>
- (void)invoke;
@end

NS_ASSUME_NONNULL_END