//
//  RxSkip
//  RxObjC
// 
//  Created by Pavel Malkov on 02.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"
#import "RxSchedulerType.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxSkipCount<Element> : RxProducer<Element> {
@package
    RxObservable *__nonnull _source;
    NSInteger _count;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source count:(NSInteger)count;

@end

@interface RxSkipTime<Element> : RxProducer<Element> {
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