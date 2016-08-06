//
//  RxSchedulers
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSchedulers.h"
#import "RxSerialDispatchQueueScheduler.h"
#import "RxDispatchQueueSchedulerQOS.h"


@implementation RxSchedulers

+ (nonnull RxSerialDispatchQueueScheduler *)userInteractive {
    return [[RxSerialDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOS:[RxDispatchQueueSchedulerQOS userInteractive]];
}

+ (nonnull RxSerialDispatchQueueScheduler *)userInitiated {
    return [[RxSerialDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOS:[RxDispatchQueueSchedulerQOS userInitiated]];
}

+ (nonnull RxSerialDispatchQueueScheduler *)default {
    return [[RxSerialDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOS:[RxDispatchQueueSchedulerQOS default]];
}

+ (nonnull RxSerialDispatchQueueScheduler *)utility {
    return [[RxSerialDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOS:[RxDispatchQueueSchedulerQOS utility]];
}

+ (nonnull RxSerialDispatchQueueScheduler *)background {
    return [[RxSerialDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOS:[RxDispatchQueueSchedulerQOS background]];
}

@end