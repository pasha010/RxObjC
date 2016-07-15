//
//  RxDispatchQueueSchedulerQOS.h
//  RxObjC
//
//  Created by Pavel Malkov on 21.06.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Identifies one of the global concurrent dispatch queues with specified quality of service class.
 */
@interface RxDispatchQueueSchedulerQOS : NSObject

@property (assign, readonly) qos_class_t QOSClass;

/** Identifies global dispatch queue with `QOS_CLASS_USER_INTERACTIVE` */
+ (nonnull instancetype)userInteractive;

/** Identifies global dispatch queue with `QOS_CLASS_USER_INITIATED` */
+ (nonnull instancetype)userInitiated;

/** Identifies global dispatch queue with `QOS_CLASS_DEFAULT` */
+ (nonnull instancetype)default;

/** Identifies global dispatch queue with `QOS_CLASS_UTILITY` */
+ (nonnull instancetype)utility;

/** Identifies global dispatch queue with `QOS_CLASS_BACKGROUND` */
+ (nonnull instancetype)background;

@end

NS_ASSUME_NONNULL_END
