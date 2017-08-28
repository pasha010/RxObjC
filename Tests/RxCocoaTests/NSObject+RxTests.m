//
//  NSObject+RxTests.m
//  RxObjC
//
//  Created by Pavel Malkov on 05.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RxTest.h"
#import <RxObjC_Dealloc/RxObjC_Dealloc.h>

@interface NSObjectRxTests : RxTest
@end

@implementation NSObjectRxTests
@end

@implementation NSObjectRxTests (RxDeallocated)

- (void)testDeallocated_ObservableFires {
    NSObject *a = [NSObject new];

    __block BOOL fired = NO;

    [[a.rx_deallocated
            map:^id(id element) {
                return @1;
            }]
            subscribeNext:^(id element) {
                fired = YES;
            }];

    XCTAssertFalse(fired);

    a = [NSObject new];

    XCTAssertTrue(fired);
}

- (void)testDeallocated_ObservableCompletes {
    NSObject *a = [NSObject new];

    __block BOOL fired = NO;

    [[a.rx_deallocated
            map:^id(id element) {
                return @1;
            }]
            subscribeCompleted:^{
                fired = YES;
            }];

    XCTAssertFalse(fired);

    a = [NSObject new];

    XCTAssertTrue(fired);
}

- (void)testDeallocated_ObservableDispose {
    NSObject *a = [NSObject new];

    __block BOOL fired = NO;

    [[[a.rx_deallocated
            map:^id(id element) {
                return @1;
            }]
            subscribeNext:^(id element) {
                fired = YES;
            }] dispose];

    XCTAssertFalse(fired);

    a = [NSObject new];

    XCTAssertFalse(fired);
}

@end