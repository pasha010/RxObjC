//
//  RxTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 19.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"
#import "RxPerformanceTools.h"

#if TRACE_RESOURCES
static int64_t RxTestsTotalNumberOfAllocations = 0;
static int64_t RxTestsTotalNumberOfAllocatedBytes = 0;
#endif

@implementation RxTest {
    int32_t _startResourceCount;
#if TRACE_RESOURCES
    int64_t _startNumberOfAllocations;
    int64_t _startNumberOfAllocatedBytes;
#endif
}

- (BOOL)accumulateStatistics {
    return YES;
}

- (void)setUp {
    [super setUp];
    [self setUpActions];
}

- (void)tearDown {
    [super tearDown];
    [self tearDownActions];
}

- (void)setUpActions {
#if TRACE_RESOURCES
//    _startResourceCount = rx_resourceCount;
//   registerMallocHooks()

//    RxMemoryInfo memoryInfo = rx_getMemoryInfo();
//    _startNumberOfAllocatedBytes = memoryInfo.bytesAllocated;
//    _startNumberOfAllocations = memoryInfo.allocCalls;

//   (startNumberOfAllocatedBytes, startNumberOfAllocations) = getMemoryInfo()
#endif
}

- (void)tearDownActions {
#if TRACE_RESOURCES
/*
    // give 5 sec to clean up resources
    for (NSUInteger i = 0; i < 30; i++) {
        if (_startResourceCount < rx_resourceCount) {
            // main schedulers need to finish work
            printf("Waiting for resource cleanup ...");
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
        } else {
            break;
        }
    }

    XCTAssertTrue(_startResourceCount == rx_resourceCount);
    RxMemoryInfo memoryInfo = rx_getMemoryInfo();

    int64_t newBytes = memoryInfo.bytesAllocated - _startNumberOfAllocatedBytes;
    int64_t newAllocations = memoryInfo.allocCalls - _startNumberOfAllocations;

    if ([self accumulateStatistics]) {
        RxTestsTotalNumberOfAllocations += newAllocations;
        RxTestsTotalNumberOfAllocatedBytes += newBytes;
    }


    printf("allocatedBytes = %lli, allocations = %lli (totalBytes = %lli, totalAllocations = %lli",
            newBytes, newAllocations, RxTestsTotalNumberOfAllocatedBytes, RxTestsTotalNumberOfAllocations);
*/

#endif
}

- (void)sleep:(NSTimeInterval)interval {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:interval]];
}


@end
