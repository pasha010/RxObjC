//
//  RxTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 19.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"

@implementation RxTest

- (void)setUp {
    [super setUp];
    [self setUpActions];
}

- (void)setUpActions {
#if TRACE_RESOURCES
    _startResourceCount = rx_resourceCount;
    /*registerMallocHooks()
            (startNumberOfAllocatedBytes, startNumberOfAllocations) = getMemoryInfo()*/
#endif
}

- (void)tearDown {
    [super tearDown];
//    [self tearDownActions];
}

- (BOOL)accumulateStatistics {
    return YES;
}

- (void)sleep:(NSTimeInterval)interval {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:interval]];
}


@end
