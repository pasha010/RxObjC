//
//  RxJust
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

@protocol RxImmediateSchedulerType;

NS_ASSUME_NONNULL_BEGIN

@interface RxJustScheduled<Element> : RxProducer<Element> {
@package
    id __nonnull _element;
    id <RxImmediateSchedulerType> __nonnull _scheduler;
}
- (instancetype)initWithElement:(nullable Element)element scheduler:(nonnull id <RxImmediateSchedulerType>)scheduler;

@end

@interface RxJust<Element> : RxProducer<Element>

- (nonnull instancetype)initWithElement:(nullable Element)element;

@end

NS_ASSUME_NONNULL_END