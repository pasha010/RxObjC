//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RxInvocableType <NSObject>
- (void)invoke;
@end

@protocol RxInvocableWithValueType <NSObject>
- (void)invoke:(nonnull id)value;
@end

NS_ASSUME_NONNULL_END