//
//  RxTestVirtualScheduler
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxVirtualTimeScheduler.h"

NS_ASSUME_NONNULL_BEGIN

/**
One virtual unit is equal to 10 seconds.
*/
@interface RxTestVirtualSchedulerVirtualTimeConverter : NSObject <RxVirtualTimeConverterType>
@end

/**
Scheduler that tests virtual scheduler
*/
@interface RxTestVirtualScheduler : RxVirtualTimeScheduler<NSNumber *, RxTestVirtualSchedulerVirtualTimeConverter *>

- (nonnull instancetype)initWithInitialClock:(NSUInteger)initialClock NS_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init;

@end

NS_ASSUME_NONNULL_END