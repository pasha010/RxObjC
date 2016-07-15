//
//  RxHistoricalScheduler
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxVirtualTimeScheduler.h"
#import "RxHistoricalSchedulerTimeConverter.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Provides a virtual time scheduler that uses `NSDate` for absolute time and `NSTimeInterval` for relative time.
*/
@interface RxHistoricalScheduler : RxVirtualTimeScheduler<RxTime *, RxHistoricalSchedulerTimeConverter *>

- (nonnull instancetype)init;

/**
 * Creates a new historical scheduler with initial clock value.
 * @param initialClock: Initial value for virtual clock.
 * @return RxHistoricalScheduler instance
 */
- (nonnull instancetype)initWithInitialClock:(RxTime *)initialClock NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END