//
//  RxObserveOn
//  RxObjC
// 
//  Created by Pavel Malkov on 26.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

@protocol RxImmediateSchedulerType;

NS_ASSUME_NONNULL_BEGIN


@interface RxObserveOn<Element> : RxProducer<Element>

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source
                             scheduler:(nonnull id <RxImmediateSchedulerType>)scheduler;

@end

NS_ASSUME_NONNULL_END