//
//  NSNotificationCenterTests.m
//  RxObjC
//
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RxTest.h"
#import "NSUserDefaults+Rx.h"

@interface NSUserDefaultsTests : RxTest

@end

@implementation NSUserDefaultsTests

- (void)testSimpleKeyObserving {
    __block NSString *lastValue = nil;
    __block NSInteger counter = 0;
    id <RxDisposable> subscription = [[[NSUserDefaults standardUserDefaults] rx_observeKey:@"test_key"]
            subscribeNext:^(NSString *s) {
                NSLog(@"s = %@", s);
                lastValue = s;
                counter++;
            }];

    XCTAssertEqualObjects(lastValue, nil);
    XCTAssertEqual(counter, 0);

    [[NSUserDefaults standardUserDefaults] setObject:@"value" forKey:@"test_key"];

    XCTAssertEqualObjects(lastValue, @"value");
    XCTAssertEqual(counter, 1);

    [[NSUserDefaults standardUserDefaults] setObject:@"another_value" forKey:@"test_key"];

    XCTAssertEqualObjects(lastValue, @"another_value");
    XCTAssertEqual(counter, 2);

    [[NSUserDefaults standardUserDefaults] setObject:@"another_value1" forKey:@"test_key1"];

    XCTAssertEqualObjects(lastValue, @"another_value");
    XCTAssertEqual(counter, 2);

    [subscription dispose];

    XCTAssertEqualObjects(lastValue, @"another_value");
    XCTAssertEqual(counter, 2);
}

@end
