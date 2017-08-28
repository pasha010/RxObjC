//
//  RxTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 19.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"
#import "RxPerformanceTools.h"

@interface RxTest ()

#if TRACE_RESOURCES
@property (class, atomic, assign) int64_t totalNumberOfAllocations;
@property (class, atomic, assign) int64_t totalNumberOfAllocatedBytes;
#endif

@end

@implementation RxTest {
#if TRACE_RESOURCES
    int32_t _startResourceCount;
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
    _startResourceCount = rx_resourceCount;
    [RxPerformanceTools.defaultTools registerMallocHooks];
    RxMemoryInfo memoryInfo = RxPerformanceTools.defaultTools.memoryInfo;
    _startNumberOfAllocatedBytes = memoryInfo.bytes;
    _startNumberOfAllocations = memoryInfo.allocations;

#endif
}

- (void)tearDownActions {
#if TRACE_RESOURCES

    // give 5 sec to clean up resources
    for (NSUInteger i = 0; i < 30; i++) {
        if (_startResourceCount < rx_resourceCount) {
            // main schedulers need to finish work
            printf("Waiting for resource cleanup ...");
            [NSRunLoop.currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
        } else {
            break;
        }
    }

    XCTAssertEqual(_startResourceCount, rx_resourceCount, "rx resource count allocations");
    
    RxMemoryInfo memoryInfo = RxPerformanceTools.defaultTools.memoryInfo;

    int64_t newBytes = memoryInfo.bytes - _startNumberOfAllocatedBytes;
    int64_t newAllocations = memoryInfo.allocations - _startNumberOfAllocations;

    if ([self accumulateStatistics]) {
        RxTest.totalNumberOfAllocatedBytes += newBytes;
        RxTest.totalNumberOfAllocations += newAllocations;
    }


    NSLog(@"allocatedBytes = %lli, allocations = %lli (totalBytes = %lli, totalAllocations = %lli)",
            newBytes, newAllocations, RxTest.totalNumberOfAllocatedBytes, RxTest.totalNumberOfAllocations);


#endif
}

- (void)sleep:(NSTimeInterval)interval {
    [NSRunLoop.currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:interval]];
}

+ (int64_t)totalNumberOfAllocations {
    NSNumber *n = objc_getAssociatedObject(self, @selector(totalNumberOfAllocations));
    return n.integerValue;
}

+ (void)setTotalNumberOfAllocations:(int64_t)totalNumberOfAllocations {
    objc_setAssociatedObject(self, @selector(totalNumberOfAllocations), @(totalNumberOfAllocations), OBJC_ASSOCIATION_RETAIN);
}

+ (int64_t)totalNumberOfAllocatedBytes {
    NSNumber *n = objc_getAssociatedObject(self, @selector(totalNumberOfAllocatedBytes));
    return n.integerValue;
}

+ (void)setTotalNumberOfAllocatedBytes:(int64_t)totalNumberOfAllocatedBytes {
    objc_setAssociatedObject(self, @selector(totalNumberOfAllocatedBytes), @(totalNumberOfAllocatedBytes), OBJC_ASSOCIATION_RETAIN);
}

@end
