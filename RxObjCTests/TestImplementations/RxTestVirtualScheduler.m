//
//  RxTestVirtualScheduler
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTestVirtualScheduler.h"

@implementation RxTestVirtualSchedulerVirtualTimeConverter

- (nonnull RxTime *)convertFromVirtualTime:(nonnull NSNumber *)virtualTime {
    return [NSDate dateWithTimeIntervalSince1970:virtualTime.doubleValue * 10.0];
}

- (nonnull NSNumber *)convertToVirtualTime:(RxTime *)time {
    return @(time.timeIntervalSince1970 / 10.0);
}

- (RxTimeInterval)convertFromVirtualTimeInterval:(NSTimeInterval)virtualTimeInterval {
    return virtualTimeInterval * 10.0;
}

- (NSTimeInterval)convertToVirtualTimeInterval:(RxTimeInterval)timeInterval {
    return timeInterval / 10.0;
}

- (nonnull NSNumber *)offsetVirtualTime:(nonnull NSNumber *)time offset:(NSTimeInterval)offset {
    return @(time.doubleValue + offset);
}

- (nonnull RxVirtualTimeComparison *)compareVirtualTime:(nonnull NSNumber *)lhs with:(nonnull NSNumber *)rhs {
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

@implementation RxTestVirtualScheduler

- (nonnull instancetype)init {
    return [self initWithInitialClock:0];
}

- (nonnull instancetype)initWithInitialClock:(NSUInteger)initialClock {
    self = [super initWithInitialClock:@(initialClock) andConverter:[[RxTestVirtualSchedulerVirtualTimeConverter alloc] init]];
    return self;
}

@end