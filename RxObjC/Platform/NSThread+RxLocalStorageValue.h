//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSThread (RxLocalStorageValue)

+ (void)rx_setThreadLocalStorageValue:(nullable id)value forKey:(nonnull id <NSCopying>)key;

+ (nullable id)rx_getThreadLocalStorageValueForKey:(nonnull id <NSCopying>)key;

@end

NS_ASSUME_NONNULL_END