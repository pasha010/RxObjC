//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxImmediateSchedulerType.h"

NS_ASSUME_NONNULL_BEGIN

@class RxVirtualTimeComparison;

typedef id RxVirtualTimeUnit;
typedef RxTimeInterval RxVirtualTimeIntervalUnit;

/**
 * Parametrization for virtual time used by `VirtualTimeScheduler`s.
 */
@protocol RxVirtualTimeConverterType <NSObject>

/**
 * Converts virtual time to real time.
 *
 * @param virtualTime: Virtual time to convert to `NSDate`.
 * @return: `NSDate` corresponding to virtual time.
*/
- (nonnull RxTime *)convertFromVirtualTime:(nonnull RxVirtualTimeUnit)virtualTime;

/**
 * Converts real time to virtual time.
 *
 * @param time: `NSDate` to convert to virtual time.
 * @return: Virtual time corresponding to `NSDate`.
*/
- (nonnull RxVirtualTimeUnit)convertToVirtualTime:(RxTime *)time;

/**
 * Converts from virtual time interval to `NSTimeInterval`.
 *
 * @param virtualTimeInterval: Virtual time interval to convert to `NSTimeInterval`.
 * @return: `NSTimeInterval` corresponding to virtual time interval.
*/
- (RxTimeInterval)convertFromVirtualTimeInterval:(RxVirtualTimeIntervalUnit)virtualTimeInterval;

/**
 * Converts from virtual time interval to `NSTimeInterval`.
 * @param timeInterval: `NSTimeInterval` to convert to virtual time interval.
 * @return: Virtual time interval corresponding to time interval.
 */
- (RxVirtualTimeIntervalUnit)convertToVirtualTimeInterval:(RxTimeInterval)timeInterval;

/**
 * Offsets virtual time by virtual time interval.
 * @param time: Virtual time.
 * @param offset: Virtual time interval.
 * @return: Time corresponding to time offsetted by virtual time interval.
 */
- (nonnull RxVirtualTimeUnit)offsetVirtualTime:(nonnull RxVirtualTimeUnit)time offset:(RxVirtualTimeIntervalUnit)offset;

/**
 * This is aditional abstraction because `NSDate` is unfortunately not comparable.
 * Extending `NSDate` with `Comparable` would be too risky because of possible collisions with other libraries.
*/
- (nonnull RxVirtualTimeComparison *)compareVirtualTime:(nonnull RxVirtualTimeUnit)lhs with:(nonnull RxVirtualTimeUnit)rhs;

@end

typedef NS_ENUM(NSUInteger, RxVirtualTimeComparisonType) {
    RxVirtualTimeComparisonTypeLessThan = 101,
    RxVirtualTimeComparisonTypeEqual = 102,
    RxVirtualTimeComparisonTypeGreaterThan = 103
};

/**
 * Virtual time comparison result.
 *
 * This is aditional abstraction because `NSDate` is unfortunately not comparable.
 * Extending `NSDate` with `Comparable` would be too risky because of possible collisions with other libraries.
*/
@interface RxVirtualTimeComparison : NSObject

@property (assign, nonatomic, readonly) RxVirtualTimeComparisonType type;
@property (assign, nonatomic, readonly) BOOL lessThan;
@property (assign, nonatomic, readonly) BOOL greaterThan;
@property (assign, nonatomic, readonly) BOOL equal;

/**
 * @code
 * lhs < rhs.
 * @endcode
 * */
+ (nonnull instancetype)lessThan;

/**
 * @code
 * lhs == rhs.
 * @endcode
*/
+ (nonnull instancetype)equal;

/**
 * @code
 * lhs > rhs.
 * @endcode
*/
+ (nonnull instancetype)greaterThan;

@end

NS_ASSUME_NONNULL_END