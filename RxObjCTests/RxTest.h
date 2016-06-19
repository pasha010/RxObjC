//
//  RxTest.h
//  RxObjC
//
//  Created by Pavel Malkov on 19.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RxObjC.h"
#import <UIKit/UIKit.h>

#if TRACE_RESOURCES
static int64_t const RxTestsTotalNumberOfAllocations = 0;
static int64_t const RxTestsTotalNumberOfAllocatedBytes = 0;
#endif

@interface RxTest : XCTestCase {
    int32_t _startResourceCount;
#if TRACE_RESOURCES
    int64_t _startNumberOfAllocations;
    int64_t _startNumberOfAllocatedBytes;
#endif
}

- (BOOL)accumulateStatistics;
- (void)sleep:(NSTimeInterval)interval;

@end
