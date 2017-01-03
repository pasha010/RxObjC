//
//  RxTimer
//  RxObjC
// 
//  Created by Pavel Malkov on 08.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"
#import "RxImmediateSchedulerType.h"

@protocol RxSchedulerType;

NS_ASSUME_NONNULL_BEGIN

@interface RxTimer<__covariant E : NSNumber *> : RxProducer<E> {
@package
    RxTimeInterval _dueTime;
    RxTimeInterval _period;
    id <RxSchedulerType> __nonnull _scheduler;
}

- (nonnull instancetype)initWithDueTime:(RxTimeInterval)aDueTime scheduler:(nonnull id <RxSchedulerType>)aScheduler;

- (nonnull instancetype)initWithDueTime:(RxTimeInterval)aDueTime
                                 period:(RxTimeInterval)aPeriod
                              scheduler:(nonnull id <RxSchedulerType>)aScheduler;


@end

NS_ASSUME_NONNULL_END