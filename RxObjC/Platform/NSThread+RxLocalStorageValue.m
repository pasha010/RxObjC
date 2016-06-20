//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "NSThread+RxLocalStorageValue.h"


@implementation NSThread (RxLocalStorageValue)

+ (void)rx_setThreadLocalStorageValue:(nullable id)value forKey:(nonnull id <NSCopying>)key {
    NSThread *currentThread = [NSThread currentThread];
    if (value) {
        currentThread.threadDictionary[key] = value;
    } else {
        [currentThread.threadDictionary removeObjectForKey:key];
    }
}

+ (nullable id)rx_getThreadLocalStorageValueForKey:(nonnull id <NSCopying>)key {
    NSThread *currentThread = [NSThread currentThread];
    return currentThread.threadDictionary[key];
}

@end