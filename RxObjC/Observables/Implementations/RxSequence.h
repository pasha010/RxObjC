//
//  RxSequence
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

@class RxImmediateScheduler;

NS_ASSUME_NONNULL_BEGIN

@interface RxSequence<Element> : RxProducer<Element> {
@package
    NSEnumerator<id> *__nonnull _elements;
    RxImmediateScheduler *__nullable _scheduler;
}

- (nonnull instancetype)initWithElements:(nonnull NSEnumerator<Element> *)elements
                               scheduler:(nullable RxImmediateScheduler *)scheduler;
@end

NS_ASSUME_NONNULL_END