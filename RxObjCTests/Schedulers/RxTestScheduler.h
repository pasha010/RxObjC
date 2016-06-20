//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxVirtualTimeScheduler.h"
#import "RxTestSchedulerVirtualTimeConverter.h"

NS_ASSUME_NONNULL_BEGIN

/**
Virtual time scheduler used for testing applications and libraries built using RxSwift.
*/

@interface RxTestScheduler : RxVirtualTimeScheduler<RxTestSchedulerVirtualTimeConverter *>
@end

NS_ASSUME_NONNULL_END