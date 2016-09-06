//
//  NSNotificationCenterTests.m
//  RxObjC
//
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RxTest.h"
#import "RxCocoa.h"

@interface NSNotificationCenterTests : RxTest

@end

@implementation NSNotificationCenterTests

- (void)testNotificationCenterWithoutObject {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    __block NSInteger numberOfNotifications = 0;

    [notificationCenter postNotificationName:@"testNotification" object:nil];

    XCTAssertTrue(numberOfNotifications == 0);

    id <RxDisposable> subscription = [[notificationCenter rx_notificationForName:@"testNotification"] subscribeNext:^(id element) {
        numberOfNotifications++;
    }];

    XCTAssertTrue(numberOfNotifications == 0);

    [notificationCenter postNotificationName:@"testNotification" object:nil];

    XCTAssertTrue(numberOfNotifications == 1);

    [notificationCenter postNotificationName:@"testNotification" object:nil];

    XCTAssertTrue(numberOfNotifications == 2);

    [subscription dispose];

    XCTAssertTrue(numberOfNotifications == 2);

    [notificationCenter postNotificationName:@"testNotification" object:nil];

    XCTAssertTrue(numberOfNotifications == 2);
}

- (void)testNotificationCenterWithObject {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    __block NSInteger numberOfNotifications = 0;

    NSObject *targetObject = [[NSObject alloc] init];

    [notificationCenter postNotificationName:@"testNotification" object:targetObject];
    [notificationCenter postNotificationName:@"testNotification" object:nil];

    XCTAssertTrue(numberOfNotifications == 0);

    id <RxDisposable> subscription = [[notificationCenter rx_notificationForName:@"testNotification" object:targetObject] subscribeNext:^(id element) {
        numberOfNotifications++;
    }];

    XCTAssertTrue(numberOfNotifications == 0);

    [notificationCenter postNotificationName:@"testNotification" object:targetObject];

    XCTAssertTrue(numberOfNotifications == 1);

    [notificationCenter postNotificationName:@"testNotification" object:[[NSObject alloc] init]];

    XCTAssertTrue(numberOfNotifications == 1);

    [notificationCenter postNotificationName:@"testNotification" object:targetObject];

    XCTAssertTrue(numberOfNotifications == 2);

    [subscription dispose];

    XCTAssertTrue(numberOfNotifications == 2);

    [notificationCenter postNotificationName:@"testNotification" object:targetObject];

    XCTAssertTrue(numberOfNotifications == 2);
}

@end
