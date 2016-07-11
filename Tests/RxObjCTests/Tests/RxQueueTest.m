//
//  RxQueueTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 19.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RxQueue.h"
#import "RxTest.h"

@interface RxQueueTest : RxTest

@end

@implementation RxQueueTest

- (void)test {
    RxQueue<NSNumber *> *queue = [[RxQueue alloc] initWithCapacity:2];

    XCTAssertEqual(queue.count, 0);
    
    for (NSUInteger i = 100; i < 200; i++) {
        [queue enqueue:@(i)];
        NSArray<NSNumber *> *allElements = [NSArray arrayWithArray:queue.array];

        NSMutableArray<NSNumber *> *correct = [NSMutableArray array];
        for (NSUInteger j = 100; j <= i; j++) {
            [correct addObject:@(j)];
        }

        BOOL isArrayEquals = [allElements isEqualToArray:correct];
        XCTAssert(isArrayEquals, @"| i = %zd", i);

        BOOL isPeekEqualTo100 = [[queue peek] isEqualToNumber:@100];
        XCTAssert(isPeekEqualTo100, @"| i = %zd", i);

        XCTAssertEqual(queue.count, i - 100 + 1, @"| i = %zd", i);
    }

    for (NSUInteger i = 100; i < 200; i++) {
        NSArray<NSNumber *> *allElements2 = [NSArray arrayWithArray:queue.array];

        NSMutableArray<NSNumber *> *correct2 = [NSMutableArray array];
        for (NSUInteger j = i; j <= 199; j++) {
            [correct2 addObject:@(j)];
        }
        BOOL isArrayEquals = [allElements2 isEqualToArray:correct2];

        XCTAssert(isArrayEquals, @"| i = %zd", i);

        BOOL isDequeueIsEqualToI = [[queue dequeue] isEqualToNumber:@(i)];
        XCTAssert(isDequeueIsEqualToI, @"| i = %zd", i);

        XCTAssertEqual(queue.count, 200 - i - 1, @"| i = %zd", i);
    }
}

- (void)testComplexity {
    RxQueue<NSNumber *> *queue = [[RxQueue alloc] initWithCapacity:2];

    XCTAssertEqual(queue.count, 0);

    for (NSUInteger i = 0; i < 200000; i++) {
        [queue enqueue:@(i)];
    }
    NSMutableArray<NSNumber *> *correct = [NSMutableArray arrayWithCapacity:200000];
    for (NSUInteger i = 0; i < 200000; i++) {
        [correct addObject:@(i)];
    }

    BOOL equals = [correct isEqualToArray:queue.array];
    XCTAssert(equals, @"failed");
}

@end
