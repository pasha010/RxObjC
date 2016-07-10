//
//  RxHistoricalSchedulerTimeConverter
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxHistoricalSchedulerTimeConverter.h"


@implementation RxHistoricalSchedulerTimeConverter

/**
 Returns identical value of argument passed because historical virtual time is equal to real time, just 
 decoupled from local machine clock.
*/
- (nonnull RxTime *)convertFromVirtualTime:(nonnull RxTime *)virtualTime {
    return virtualTime;
}

/**
 Returns identical value of argument passed because historical virtual time is equal to real time, just 
 decoupled from local machine clock.
*/
- (nonnull RxTime *)convertToVirtualTime:(nonnull RxTime *)time {
    return time;
}

/**
 Returns identical value of argument passed because historical virtual time is equal to real time, just 
 decoupled from local machine clock.
*/
- (RxTimeInterval)convertFromVirtualTimeInterval:(RxTimeInterval)virtualTimeInterval {
    return virtualTimeInterval;
}

/**
 Returns identical value of argument passed because historical virtual time is equal to real time, just 
 decoupled from local machine clock.
*/
- (RxTimeInterval)convertToVirtualTimeInterval:(RxTimeInterval)timeInterval {
    return timeInterval;
}

/**
 Offsets `NSDate` by time interval.
 
 - parameter time: Time.
 - parameter timeInterval: Time interval offset.
 - returns: Time offsetted by time interval.
*/
- (nonnull RxTime *)offsetVirtualTime:(nonnull RxTime *)time offset:(RxTimeInterval)offset {
    return [time dateByAddingTimeInterval:offset];
}

/**
 Compares two `NSDate`s.
*/
- (nonnull RxVirtualTimeComparison *)compareVirtualTime:(nonnull RxTime *)lhs with:(nonnull RxTime *)rhs {
    NSComparisonResult result = [lhs compare:rhs];
    if (result == NSOrderedAscending) {
        return [RxVirtualTimeComparison lessThan];
    } else if (result == NSOrderedSame) {
        return [RxVirtualTimeComparison equal];
    } else {
        return [RxVirtualTimeComparison greaterThan];
    }
}


@end