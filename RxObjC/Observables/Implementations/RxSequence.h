//
//  RxSequence
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

@protocol RxImmediateSchedulerType;

NS_ASSUME_NONNULL_BEGIN

@interface RxSequence<Element> : RxProducer<Element> {
@package
    NSArray<id> *__nonnull _elements;
    id <RxImmediateSchedulerType> __nullable _scheduler;
}

- (nonnull instancetype)initWithElements:(nonnull NSArray<Element> *)elements
                               scheduler:(nullable id <RxImmediateSchedulerType>)scheduler;
@end

NS_ASSUME_NONNULL_END