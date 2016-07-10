//
//  RxAssumptionsTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RxTest.h"
#import "RxObservable+Creation.h"

@interface RxAnything : NSObject 
- (void)justCallIt:(void(^)(void))action;
@end

BOOL rx_deallocated = NO;
RxAnything *rx_realTest = nil;

void rx_clearRealTest() {
    rx_realTest = nil;
}

RxObservable *rx_returnSomethingNull() {
    return [RxObservable just:[NSNull null]];
}

RxObservable<NSNumber *> *rx_returnSomethingInt() {
    return [RxObservable just:@3];
}

@implementation RxAnything {
    NSMutableArray<NSNumber *> *__nonnull _elements;
}

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _elements = [NSMutableArray array];
    }
    return self;
}

- (void)justCallIt:(void (^)(void))action {
    rx_clearRealTest();
    action();
}

- (void)dealloc {
    rx_deallocated = YES;
}

@end

@interface RxAssumptionsTest : RxTest
@end

@implementation RxAssumptionsTest

- (void)testAssumptionInCodeIsThatArraysAreStructs {
    NSMutableArray<NSString *> *a = [@[@"a"] mutableCopy];
    NSMutableArray<NSString *> *b = [a mutableCopy];

    [b addObject:@"b"];

    XCTAssertTrue([a isEqualToArray:@[@"a"]]);
    
    NSArray *array = @[@"a", @"b"];
    XCTAssertTrue([b isEqualToArray:array]);
}

- (void)testFunctionCallRetainsArguments {
    // first check is dealloc method working

    RxAnything *a = [[RxAnything alloc] init];

    NSLog(@"%@", a);
    XCTAssertFalse(rx_deallocated);
    a = nil;
    XCTAssertTrue(rx_deallocated);

    // then check unsafe
    rx_deallocated = NO;

    rx_realTest = [[RxAnything alloc] init];
    
    XCTAssertFalse(rx_deallocated);

    [rx_realTest justCallIt:^{
        XCTAssertTrue(rx_deallocated);
        rx_realTest = nil;
        XCTAssertTrue(rx_deallocated);
    }];
    
//    XCTAssertTrue(rx_deallocated);
}

- (void)testFunctionReturnValueOverload {
    [rx_returnSomethingNull() subscribeNext:^(id o) {
        NSNull *n = o;
        XCTAssertTrue(n == [NSNull null]);
    }];

    [rx_returnSomethingInt() subscribeNext:^(NSNumber *n) {
        XCTAssertTrue([n isEqualToNumber:@3]);
    }];
}

- (void)testArrayMutation {
    NSMutableArray<NSNumber *> *a = [@[@1, @2, @3, @4] mutableCopy];
    NSMutableArray<NSNumber *> *b = [a mutableCopy];
    
    NSUInteger count = 0;
    for (NSNumber *_ in b) {
        [a removeAllObjects];
        count++;
    }
    XCTAssertTrue(count == 4);
}

- (void)testResourceLeaksDetectionIsTurnedOn {
#if TRACE_RESOURCES
    int32_t startResourceCount = rx_resourceCount;

    RxObservable<NSNumber *> *observable = [RxObservable just:@1];

    XCTAssertTrue(observable != nil);
    XCTAssertTrue(rx_resourceCount == startResourceCount + 1);

    observable = nil;

    XCTAssertTrue(rx_resourceCount == startResourceCount);
#elif RELEASE
    XCTAssert(NO, @"Can't run unit tests in without tracing");
#endif

}

@end
