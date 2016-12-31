//
//  RxBufferTimeCount
//  RxObjC
// 
//  Created by Pavel Malkov on 08.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"
#import "RxImmediateSchedulerType.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxBufferTimeCount<Element> : RxProducer<Element> {
@package
    RxObservable<Element> *__nonnull _source;
    RxTimeInterval _timeSpan;
    NSUInteger _count;
    id <RxSchedulerType> __nonnull _scheduler;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<Element> *)source
                              timeSpan:(RxTimeInterval)timeSpan
                                 count:(NSUInteger)count
                             scheduler:(nonnull id <RxSchedulerType>)scheduler;

@end

NS_ASSUME_NONNULL_END