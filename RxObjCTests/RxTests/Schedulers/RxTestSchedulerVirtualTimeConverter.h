//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxVirtualTimeConverterType.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Converter from virtual time and time interval measured in `Int`s to `NSDate` and `NSTimeInterval`.
*/
@interface RxTestSchedulerVirtualTimeConverter : NSObject <RxVirtualTimeConverterType>

- (nonnull instancetype)initWithResolution:(double)resolution;

/**
 Converts virtual time to real time.

 - parameter virtualTime: Virtual time to convert to `NSDate`.
 - returns: `NSDate` corresponding to virtual time.
 */
- (nonnull NSDate *)convertFromVirtualTime:(nonnull NSNumber *)virtualTime;

/**
 Converts real time to virtual time.

 - parameter time: `NSDate` to convert to virtual time.
 - returns: Virtual time corresponding to `NSDate`.
 */
- (NSNumber *)convertToVirtualTime:(nonnull RxTime *)time;

/**
 Converts from virtual time interval to `NSTimeInterval`.

 - parameter virtualTimeInterval: Virtual time interval to convert to `NSTimeInterval`.
 - returns: `NSTimeInterval` corresponding to virtual time interval.
 */
- (RxTimeInterval)convertFromVirtualTimeInterval:(RxTimeInterval)virtualTimeInterval;

/**
 Converts from virtual time interval to `NSTimeInterval`.

 - parameter timeInterval: `NSTimeInterval` to convert to virtual time interval.
 - returns: Virtual time interval corresponding to time interval.
 */
- (RxTimeInterval)convertToVirtualTimeInterval:(RxTimeInterval)timeInterval;

/**
 Adds virtual time and virtual time interval.

 - parameter time: Virtual time.
 - parameter offset: Virtual time interval.
 - returns: Time corresponding to time offsetted by virtual time interval.
 */
- (nonnull NSNumber *)offsetVirtualTime:(nonnull NSNumber *)time offset:(RxTimeInterval)offset;

/**
 Compares virtual times.
*/
- (nonnull RxVirtualTimeComparison *)compareVirtualTime:(nonnull NSNumber *)lhs with:(nonnull NSNumber *)rhs;

@end

NS_ASSUME_NONNULL_END