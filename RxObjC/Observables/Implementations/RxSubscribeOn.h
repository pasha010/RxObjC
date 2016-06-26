//
//  RxSubscribeOn
//  RxObjC
// 
//  Created by Pavel Malkov on 26.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

@protocol RxImmediateSchedulerType;

NS_ASSUME_NONNULL_BEGIN

@interface RxSubscribeOn<O : id<RxObservableType>> : RxProducer {
@package
    id <RxImmediateSchedulerType> __nonnull _scheduler;
    id<RxObservableType> __nonnull _source;
}

- (nonnull instancetype)initWithSource:(nonnull id<RxObservableType>)source
                             scheduler:(nonnull id <RxImmediateSchedulerType>)scheduler;

@end
NS_ASSUME_NONNULL_END