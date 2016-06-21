//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTestSchedulerVirtualTimeConverter.h"


@implementation RxTestSchedulerVirtualTimeConverter {
    double _resolution;
}

- (nonnull instancetype)initWithResolution:(double)resolution {
    self = [super init];
    if (self) {
        _resolution = resolution;
    }
    return self;
}

- (nonnull NSDate *)convertFromVirtualTime:(nonnull NSNumber *)virtualTime {
    return [NSDate dateWithTimeIntervalSince1970:virtualTime.doubleValue * _resolution];
}

- (nonnull NSNumber *)convertToVirtualTime:(nonnull RxTime *)time {
    return @(time.timeIntervalSince1970 / _resolution + 0.5);
}

- (RxTimeInterval)convertFromVirtualTimeInterval:(nonnull NSNumber *)virtualTimeInterval {
    return virtualTimeInterval.doubleValue * _resolution;
}

- (nonnull NSNumber *)convertToVirtualTimeInterval:(RxTimeInterval)timeInterval {
    return @(timeInterval / _resolution + 0.5);
}

- (nonnull NSNumber *)offsetVirtualTime:(nonnull NSNumber *)time offset:(nonnull NSNumber *)offset {
    return @(time.doubleValue + offset.doubleValue);
}

- (nonnull RxVirtualTimeComparison *)compareVirtualTime:(nonnull NSNumber *)_lhs with:(nonnull NSNumber *)_rhs {
    NSTimeInterval lhs = _lhs.doubleValue;
    NSTimeInterval rhs = _rhs.doubleValue;

    if (lhs < rhs) {
        return [RxVirtualTimeComparison lessThan];
    } else if (lhs > rhs) {
        return [RxVirtualTimeComparison greaterThan];
    } else {
        return [RxVirtualTimeComparison equal];
    }
}


@end