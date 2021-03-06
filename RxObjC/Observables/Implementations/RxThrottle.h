//
//  RxThrottle
//  RxObjC
// 
//  Created by Pavel Malkov on 04.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"
#import "RxImmediateSchedulerType.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxThrottle<Element> : RxProducer<Element> {
@package
    RxObservable<Element> *__nonnull _source;
    RxTimeInterval _dueTime;
    id <RxSchedulerType> __nonnull _scheduler;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<Element> *)source dueTime:(RxTimeInterval)dueTime scheduler:(nonnull id <RxSchedulerType>)scheduler;


@end

@interface RxThrottleFirst<Element> : RxProducer<Element> {
@package
    RxObservable<Element> *__nonnull _source;
    RxTimeInterval _dueTime;
    id <RxSchedulerType> __nonnull _scheduler;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<Element> *)source dueTime:(RxTimeInterval)dueTime scheduler:(nonnull id <RxSchedulerType>)scheduler;


@end

NS_ASSUME_NONNULL_END