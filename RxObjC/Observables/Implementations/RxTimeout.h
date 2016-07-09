//
//  RxTimeout
//  RxObjC
// 
//  Created by Pavel Malkov on 09.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"
#import "RxSchedulerType.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxTimeout<Element> : RxProducer<Element> {
@package
    RxObservable<Element> *__nonnull _source;
    RxTimeInterval _dueTime;
    RxObservable<Element> *__nonnull _other;
    id <RxSchedulerType> __nonnull _scheduler;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<Element> *)source
                               dueTime:(RxTimeInterval)dueTime
                                 other:(nonnull RxObservable<Element> *)other
                             scheduler:(nonnull id <RxSchedulerType>)scheduler;


@end

NS_ASSUME_NONNULL_END