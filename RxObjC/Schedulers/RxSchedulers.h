//
//  RxSchedulers
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RxSerialDispatchQueueScheduler;

NS_ASSUME_NONNULL_BEGIN

/**
 * It's serial schedulers factory for creating RxSerialDispatchQueueScheduler class instances
 */
@interface RxSchedulers : NSObject

+ (nonnull RxSerialDispatchQueueScheduler *)userInteractive;

+ (nonnull RxSerialDispatchQueueScheduler *)userInitiated;

+ (nonnull RxSerialDispatchQueueScheduler *)default;

+ (nonnull RxSerialDispatchQueueScheduler *)utility;

+ (nonnull RxSerialDispatchQueueScheduler *)background;

@end

NS_ASSUME_NONNULL_END