//
//  RxObservable+MultipleTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"
#import "RxObservable+Creation.h"
#import "RxObservable+Multiple.h"
#import "RxTestScheduler.h"
#import "XCTest+Rx.h"
#import "RxTestableObserver.h"
#import "RxTestableObservable.h"
#import "RxSubscription.h"

@interface RxObservableMultipleTest : RxTest

@end

@implementation RxObservableMultipleTest

@end

@implementation RxObservableMultipleTest (Concat)

- (void)testConcat_DefaultScheduler {
    __block int sum = 0;
    [[@[[RxObservable just:@1], [RxObservable just:@2], [RxObservable just:@3]] concat] subscribeNext:^(NSNumber *e) {
        sum += e.intValue;
    }];

    XCTAssertTrue(sum == 6, @"sum = %d", sum);
}

- (void)testConcat_IEofIO {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createColdObservable:@[
            [self next:10 element:@1],
            [self next:20 element:@2],
            [self next:30 element:@3],
            [self completed:40]
    ]];

    RxTestableObservable *xs2 = [scheduler createColdObservable:@[
            [self next:10 element:@4],
            [self next:20 element:@5],
            [self completed:30]
    ]];

    RxTestableObservable *xs3 = [scheduler createColdObservable:@[
            [self next:10 element:@6],
            [self next:20 element:@7],
            [self next:30 element:@8],
            [self next:40 element:@9],
            [self completed:50]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return @[xs1, xs2, xs3].concat;
    }];

    NSArray *messages = @[
            [self next:210 element:@1],
            [self next:220 element:@2],
            [self next:230 element:@3],
            [self next:250 element:@4],
            [self next:260 element:@5],
            [self next:280 element:@6],
            [self next:290 element:@7],
            [self next:300 element:@8],
            [self next:310 element:@9],
            [self completed:320]
    ];

    XCTAssertTrue([res.events isEqualToArray:messages]);

    XCTAssertTrue([xs1.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:200 unsubscribe:240]]]);
    XCTAssertTrue([xs2.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:240 unsubscribe:270]]]);
    XCTAssertTrue([xs3.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:270 unsubscribe:320]]]);
}

- (void)testConcat_EmptyEmpty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self completed:230]
    ]];

    RxTestableObservable *xs2 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self completed:250]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return @[xs1, xs2].concat;
    }];

    XCTAssertTrue([res.events isEqualToArray:@[[self completed:250]]]);
    XCTAssertTrue([xs1.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:200 unsubscribe:230]]]);
    XCTAssertTrue([xs2.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:230 unsubscribe:250]]]);
}

// TODO complete this

@end
