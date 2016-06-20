//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxSchedulerType.h"

NS_ASSUME_NONNULL_BEGIN

@class RxVirtualTimeComparison;

typedef id RxVirtualTimeUnit;
typedef id RxVirtualTimeIntervalUnit;

/**
Parametrization for virtual time used by `VirtualTimeScheduler`s.
*/
@protocol RxVirtualTimeConverterType <NSObject>

/**
 Converts virtual time to real time.

 - parameter virtualTime: Virtual time to convert to `NSDate`.
 - returns: `NSDate` corresponding to virtual time.
*/
- (RxTime *)convertFromVirtualTime:(nonnull RxVirtualTimeUnit)virtualTime;

/**
 Converts real time to virtual time.

 - parameter time: `NSDate` to convert to virtual time.
 - returns: Virtual time corresponding to `NSDate`.
*/
- (nonnull RxVirtualTimeUnit)convertToVirtualTime:(RxTime *)time;

/**
 Converts from virtual time interval to `NSTimeInterval`.

 - parameter virtualTimeInterval: Virtual time interval to convert to `NSTimeInterval`.
 - returns: `NSTimeInterval` corresponding to virtual time interval.
*/
- (RxTimeInterval)convertFromVirtualTimeInterval:(nonnull RxVirtualTimeIntervalUnit)virtualTimeInterval;

/**
 Converts from virtual time interval to `NSTimeInterval`.

 - parameter timeInterval: `NSTimeInterval` to convert to virtual time interval.
 - returns: Virtual time interval corresponding to time interval.
*/
- (nonnull RxVirtualTimeIntervalUnit)convertToVirtualTimeInterval:(RxTimeInterval)timeInterval;

/**
 Offsets virtual time by virtual time interval.

 - parameter time: Virtual time.
 - parameter offset: Virtual time interval.
 - returns: Time corresponding to time offsetted by virtual time interval.
*/
- (nonnull RxVirtualTimeUnit)offsetVirtualTime:(RxVirtualTimeUnit)time offset:(RxVirtualTimeIntervalUnit)offset;

/**
 This is aditional abstraction because `NSDate` is unfortunately not comparable.
 Extending `NSDate` with `Comparable` would be too risky because of possible collisions with other libraries.
*/
- (nonnull RxVirtualTimeComparison *)compareVirtualTime:(nonnull RxVirtualTimeUnit)lhs with:(nonnull RxVirtualTimeUnit)rhs;

@end

typedef NS_ENUM(NSUInteger, RxVirtualTimeComparisonType) {
    RxVirtualTimeComparisonTypeLessThan = 101,
    RxVirtualTimeComparisonTypeEqual = 102,
    RxVirtualTimeComparisonTypeGreaterThan = 103
};

/**
 Virtual time comparison result.

 This is aditional abstraction because `NSDate` is unfortunately not comparable.
 Extending `NSDate` with `Comparable` would be too risky because of possible collisions with other libraries.
*/
@interface RxVirtualTimeComparison : NSObject

@property (assign, nonatomic) RxVirtualTimeComparisonType type;
@property (assign, nonatomic) BOOL lessThan;
@property (assign, nonatomic) BOOL greaterThan;
@property (assign, nonatomic) BOOL equal;

/**
 lhs < rhs.
*/
+ (nonnull instancetype)lessThan;

/**
 lhs == rhs.
*/
+ (nonnull instancetype)equal;

/**
 lhs > rhs.
*/
+ (nonnull instancetype)greaterThan;

@end

NS_ASSUME_NONNULL_END