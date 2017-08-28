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

@property (class, nonnull, readonly) RxSerialDispatchQueueScheduler *userInteractive NS_AVAILABLE(10_10, 8_0);
@property (class, nonnull, readonly) RxSerialDispatchQueueScheduler *userInitiated NS_AVAILABLE(10_10, 8_0);
@property (class, nonnull, readonly) RxSerialDispatchQueueScheduler *utility NS_AVAILABLE(10_10, 8_0);
@property (class, nonnull, readonly) RxSerialDispatchQueueScheduler *background NS_AVAILABLE(10_10, 8_0);

+ (nonnull RxSerialDispatchQueueScheduler *)default NS_AVAILABLE(10_10, 8_0);

@end

NS_ASSUME_NONNULL_END