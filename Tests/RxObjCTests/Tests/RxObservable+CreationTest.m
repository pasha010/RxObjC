//
//  RxObservable+CreationTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 10.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"
#import <RxBlocking/RxBlockingObservable+Operators.h>
#import "XCTest+Rx.h"

@interface RxObservableCreationTest : RxTest

@end

@implementation RxObservableCreationTest
@end

@implementation RxObservableCreationTest (Just)

- (void)testJust_Immediate {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable just:@42];
    }];

    NSArray *array = @[
            [self next:RxTestSchedulerDefaultSubscribed element:@42],
            [self completed:RxTestSchedulerDefaultSubscribed]
    ];

    XCTAssert([res.events isEqualToArray:array]);
}

- (void)testJust_Basic {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable just:@42 scheduler:scheduler];
    }];

    NSArray *array = @[
            [self next:201 element:@42],
            [self completed:202]
    ];

    XCTAssert([res.events isEqualToArray:array]);
}

- (void)testJust_Disposed {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler start:200 create:^RxObservable * {
        return [RxObservable just:@42 scheduler:scheduler];
    }];

    XCTAssert([res.events isEqualToArray:@[]]);
}

- (void)testJust_DisposeAfterNext {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxSingleAssignmentDisposable *d = [[RxSingleAssignmentDisposable alloc] init];

    RxTestableObserver<NSNumber *> *res = [scheduler createObserver];

    [scheduler scheduleAt:100 action:^{
        d.disposable = [[RxObservable just:@42 scheduler:scheduler] subscribeWith:^(RxEvent<NSNumber *> *event) {
            [res on:event];
            if (event.type == RxEventTypeNext) {
                [d dispose];
            }
        }];
    }];

    [scheduler start];

    XCTAssert([res.events isEqualToArray:@[[self next:101 element:@42]]]);
}

- (void)testJust_DefaultScheduler {
    NSArray<NSNumber *> *res = [[[RxObservable just:@42 scheduler:[RxMainScheduler sharedInstance]] toBlocking] blocking_toArray];
    XCTAssert([res isEqualToArray:@[@42]]);
}

@end
