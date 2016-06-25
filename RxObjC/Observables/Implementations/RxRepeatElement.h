//
//  RxRepeatElement
//  RxObjC
// 
//  Created by Pavel Malkov on 25.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

@protocol RxImmediateSchedulerType;

NS_ASSUME_NONNULL_BEGIN

@interface RxRepeatElement<Element> : RxProducer<Element> {
@package
    id __nonnull _element;
    id <RxImmediateSchedulerType> __nonnull _scheduler;
}

- (nonnull instancetype)initWithElement:(nonnull id)element
                              scheduler:(nonnull id <RxImmediateSchedulerType>)scheduler;

@end

NS_ASSUME_NONNULL_END