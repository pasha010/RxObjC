//
//  RxDispatchQueueSchedulerQOS.m
//  RxObjC
//
//  Created by Pavel Malkov on 21.06.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import "RxDispatchQueueSchedulerQOS.h"

@implementation RxDispatchQueueSchedulerQOS

+ (nonnull instancetype)userInteractive {
    static dispatch_once_t token;
    static RxDispatchQueueSchedulerQOS *instance;
    dispatch_once(&token, ^{
        instance = [[RxDispatchQueueSchedulerQOS alloc] initWithType:QOS_CLASS_USER_INTERACTIVE];
    });
    return instance;
}

+ (nonnull instancetype)userInitiated {
    static dispatch_once_t token;
    static RxDispatchQueueSchedulerQOS *instance;
    dispatch_once(&token, ^{
        instance = [[RxDispatchQueueSchedulerQOS alloc] initWithType:QOS_CLASS_USER_INITIATED];
    });
    return instance;
}

+ (nonnull instancetype)default {
    static dispatch_once_t token;
    static RxDispatchQueueSchedulerQOS *instance;
    dispatch_once(&token, ^{
        instance = [[RxDispatchQueueSchedulerQOS alloc] initWithType:QOS_CLASS_DEFAULT];
    });
    return instance;
}

+ (nonnull instancetype)utility {
    static dispatch_once_t token;
    static RxDispatchQueueSchedulerQOS *instance;
    dispatch_once(&token, ^{
        instance = [[RxDispatchQueueSchedulerQOS alloc] initWithType:QOS_CLASS_UTILITY];
    });
    return instance;
}

+ (nonnull instancetype)background {
    static dispatch_once_t token;
    static RxDispatchQueueSchedulerQOS *instance;
    dispatch_once(&token, ^{
        instance = [[RxDispatchQueueSchedulerQOS alloc] initWithType:QOS_CLASS_BACKGROUND];
    });
    return instance;
}

- (nonnull instancetype)initWithType:(qos_class_t)type {
    self = [super init];
    if (self) {
        _QOSClass = type;
    }
    return self;
}

@end
