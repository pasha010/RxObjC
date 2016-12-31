//
//  RxRange
//  RxObjC
// 
//  Created by Pavel Malkov on 25.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

@class RxImmediateScheduler;

NS_ASSUME_NONNULL_BEGIN

@interface RxRangeProducer : RxProducer<NSNumber *> {
@package
    NSInteger _start;
    NSUInteger _count;
    RxImmediateScheduler *__nonnull _scheduler;
}

- (nonnull instancetype)initWithStart:(NSInteger)start
                                count:(NSUInteger)count
                            scheduler:(nonnull RxImmediateScheduler *)scheduler;

@end

NS_ASSUME_NONNULL_END