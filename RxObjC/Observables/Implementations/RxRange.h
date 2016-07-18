//
//  RxRange
//  RxObjC
// 
//  Created by Pavel Malkov on 25.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

@protocol RxImmediateSchedulerType;

NS_ASSUME_NONNULL_BEGIN

@interface RxRangeProducer : RxProducer<NSNumber *> {
@package
    NSInteger _start;
    NSUInteger _count;
    id <RxImmediateSchedulerType> __nonnull _scheduler;
}

- (nonnull instancetype)initWithStart:(NSInteger)start
                                count:(NSUInteger)count
                            scheduler:(nonnull id <RxImmediateSchedulerType>)scheduler;

@end

NS_ASSUME_NONNULL_END