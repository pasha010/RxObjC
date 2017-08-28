//
//  RxSchedulers
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSchedulers.h"
#import "RxSerialDispatchQueueScheduler.h"

@implementation RxSchedulers

+ (nonnull RxSerialDispatchQueueScheduler *)userInteractive {
    return [[RxSerialDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOSClass:QOS_CLASS_USER_INTERACTIVE];
}

+ (nonnull RxSerialDispatchQueueScheduler *)userInitiated {
    return [[RxSerialDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOSClass:QOS_CLASS_USER_INITIATED];
}

+ (nonnull RxSerialDispatchQueueScheduler *)default {
    return [[RxSerialDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOSClass:QOS_CLASS_DEFAULT];
}

+ (nonnull RxSerialDispatchQueueScheduler *)utility {
    return [[RxSerialDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOSClass:QOS_CLASS_UTILITY];
}

+ (nonnull RxSerialDispatchQueueScheduler *)background {
    return [[RxSerialDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOSClass:QOS_CLASS_BACKGROUND];
}

@end