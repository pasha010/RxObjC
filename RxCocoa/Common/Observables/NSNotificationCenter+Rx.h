//
//  NSNotificationCenter(Rx)
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RxObjC/RxObjC.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNotificationCenter (Rx)
/**
 * Transforms notifications posted to notification center to observable sequence of notifications.
 * @param name: Filter notifications by name.
 * @param object: Optional object used to filter notifications.
 * @return: Observable sequence of posted notifications.
 */
- (nonnull RxObservable<NSNotification *> *)rx_notificationForName:(nullable NSString *)name object:(nullable id)object;

- (nonnull RxObservable<NSNotification *> *)rx_notificationForName:(nullable NSString *)name;

@end

NS_ASSUME_NONNULL_END