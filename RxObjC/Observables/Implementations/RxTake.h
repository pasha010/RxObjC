//
//  RxTake
//  RxObjC
// 
//  Created by Pavel Malkov on 02.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"
#import "RxImmediateSchedulerType.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxTakeCount<Element> : RxProducer<Element> {
@package
    RxObservable<Element> *__nonnull _source;
    NSUInteger _count;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<Element> *)source count:(NSUInteger)count;

@end

@interface RxTakeTime<Element> : RxProducer<Element> {
@package
    RxObservable<Element> *__nonnull _source;
    RxTimeInterval _duration;
    id <RxSchedulerType> __nonnull _scheduler;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<Element> *)source
                              duration:(RxTimeInterval)duration
                             scheduler:(nonnull id <RxSchedulerType>)scheduler;


@end

NS_ASSUME_NONNULL_END