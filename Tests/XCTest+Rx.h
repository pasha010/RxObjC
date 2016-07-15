//
//  XCTest(Rx)
//  RxObjC
// 
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "RxTests.h"

@class RxEvent;

NS_ASSUME_NONNULL_BEGIN

/**
These methods are conceptually extensions of `XCTestCase` but because referencing them in closures would
require specifying `self.*`, they are made global.
*/
@interface XCTest (Rx)
/**
Factory method for an `.Next` event recorded at a given time with a given value.

 - parameter time: Recorded virtual time the `.Next` event occurs.
 - parameter element: Next sequence element.
 - returns: Recorded event in time.
*/
- (nonnull RxRecorded<RxEvent *> *)next:(RxTestTime)time element:(nonnull id)element;
- (nonnull RxRecorded<RxEvent *> *)next:(nonnull id)element;

/**
Factory method for an `.Completed` event recorded at a given time.

 - parameter time: Recorded virtual time the `.Completed` event occurs.
 - parameter type: Sequence elements type.
 - returns: Recorded event in time.
*/
- (nonnull RxRecorded<RxEvent *> *)completed:(RxTestTime)time;
- (nonnull RxRecorded<RxEvent *> *)completed;

/**
Factory method for an `.Error` event recorded at a given time with a given error.

 - parameter time: Recorded virtual time the `.Completed` event occurs.
*/
- (nonnull RxRecorded<RxEvent *> *)error:(RxTestTime)time testError:(nonnull NSError *)error;
- (nonnull RxRecorded<RxEvent *> *)error:(nonnull NSError *)error;

@end

NS_ASSUME_NONNULL_END