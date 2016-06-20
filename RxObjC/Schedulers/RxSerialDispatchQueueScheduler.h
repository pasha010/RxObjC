//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxSchedulerType.h"

NS_ASSUME_NONNULL_BEGIN

/**
Abstracts the work that needs to be performed on a specific `dispatch_queue_t`. It will make sure
that even if concurrent dispatch queue is passed, it's transformed into a serial one.

It is extremely important that this scheduler is serial, because
certain operator perform optimizations that rely on that property.

Because there is no way of detecting is passed dispatch queue serial or
concurrent, for every queue that is being passed, worst case (concurrent)
will be assumed, and internal serial proxy dispatch queue will be created.

This scheduler can also be used with internal serial queue alone.

In case some customization need to be made on it before usage,
internal serial queue can be customized using `serialQueueConfiguration`
callback.
*/
@interface RxSerialDispatchQueueScheduler : NSObject <RxSchedulerType>
@end

NS_ASSUME_NONNULL_END