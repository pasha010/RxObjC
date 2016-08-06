//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxSerialDispatchQueueScheduler.h"

NS_ASSUME_NONNULL_BEGIN

/**

*/
/**
 * Abstracts work that needs to be performed on `MainThread`. In case `schedule` methods are called from main thread, it will perform action immediately without scheduling.
 *
 * This scheduler is usually used to perform UI work.
 *
 * Main scheduler is a specialization of `SerialDispatchQueueScheduler`.
 *
 * This scheduler is optimized for `observeOn` operator. To ensure observable sequence is subscribed on main thread using `subscribeOn`
 * operator please use `ConcurrentMainScheduler` because it is more optimized for that purpose.
 */
@interface RxMainScheduler : RxSerialDispatchQueueScheduler

/**
 * Singleton instance of `MainScheduler`
 * @return instance of `MainScheduler`
 */
+ (nonnull instancetype)sharedInstance;

/**
 * Singleton instance of `MainScheduler`
 * @return instance of `MainScheduler`
 */
+ (nonnull instancetype)instance;

/**
 * Singleton instance of `MainScheduler` that always schedules work asynchronously
 * and doesn't perform optimizations for calls scheduled from main thread.
 * @return instance of `MainScheduler`
 */
+ (nonnull RxSerialDispatchQueueScheduler *)asyncInstance;

/**
 * In case this method is called on a background thread it will throw an exception.
 */
+ (void)ensureExecutingOnScheduler;

@end

NS_ASSUME_NONNULL_END