//
//  RxObservable+SingleTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 10.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"
#import "RxPrimitiveHotObservable.h"

@interface RxObservableSingleTest : RxTest

@end

@implementation RxObservableSingleTest
@end

@implementation RxObservableSingleTest (Creation)

- (void)testAsObservable_asObservable {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(220, @2),
            completed(250)
    ]];

    RxObservable *ys = [xs asObservable];
    
    XCTAssert(![ys isEqual:xs]);

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return ys;
    }];

    NSArray *correct = @[
            next(220, @2),
            completed(250)
    ];
    XCTAssertEqualObjects(res.events, correct);
}

- (void)testAsObservable_hides {
    RxPrimitiveHotObservable *xs = [[RxPrimitiveHotObservable alloc] init];
    RxObservable *res = [xs asObservable];
    XCTAssert(![xs isEqual:res]);
}

- (void)testAsObservable_never {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxObservable *xs = [RxObservable never];

    RxTestableObserver *res = [scheduler startWithObservable:xs];

    NSArray *correct = @[
    ];
    XCTAssertEqualObjects(res.events, correct);

}

@end

@implementation RxObservableSingleTest (Distinct)

- (void)testDistinctUntilChanged_allChanges {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs distinctUntilChangedWithKeySelector:^id(id o) { return o; }]];

    NSArray *correctMessages = @[
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ];
    XCTAssertEqualObjects(res.events, correctMessages);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 250)]);
}

- (void)testDistinctUntilChanged_someChanges {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2), // *
            next(215, @3), // *
            next(220, @3),
            next(225, @2), // *
            next(230, @2),
            next(230, @1), // *
            next(240, @2), // *
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs distinctUntilChangedWithKeySelector:^id(id o) { return o; }]];

    NSArray *correctMessages = @[
            next(210, @2),
            next(215, @3),
            next(225, @2),
            next(230, @1),
            next(240, @2),
            completed(250)
    ];
    XCTAssertEqualObjects(res.events, correctMessages);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 250)]);
}

- (void)testDistinctUntilChanged_allEqual {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs distinctUntilChangedWithComparer:^BOOL(id lhs, id rhs) { return YES; }]];

    NSArray *correctMessages = @[
            next(210, @2),
            completed(250)
    ];
    XCTAssertEqualObjects(res.events, correctMessages);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 250)]);
}

- (void)testDistinctUntilChanged_allDifferent {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @2),
            next(230, @2),
            next(240, @2),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs distinctUntilChangedWithComparer:^BOOL(id lhs, id rhs) { return NO; }]];

    NSArray *correctMessages = @[
            next(210, @2),
            next(220, @2),
            next(230, @2),
            next(240, @2),
            completed(250)
    ];
    XCTAssertEqualObjects(res.events, correctMessages);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 250)]);
}

- (void)testDistinctUntilChanged_keySelector_Div2 {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @4),
            next(230, @3),
            next(240, @5),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs distinctUntilChangedWithKeySelector:^NSNumber *(NSNumber *o) {
        return @(o.integerValue % 2);
    }]];

    NSArray *correctMessages = @[
            next(210, @2),
            next(230, @3),
            completed(250)
    ];
    XCTAssertEqualObjects(res.events, correctMessages);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 250)]);
}

- (void)testDistinctUntilChanged_keySelectorThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs distinctUntilChangedWithKeySelector:^NSNumber *(NSNumber *o) {
        @throw testError();
    }]];

    NSArray *correctMessages = @[
            error(210, testError())
    ];
    XCTAssertEqualObjects(res.events, correctMessages);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 210)]);
}

- (void)testDistinctUntilChanged_comparerThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs distinctUntilChanged:^id(id o) {
        return o;
    } comparer:^BOOL(id lhs, id rhs) {
        @throw testError();
    }]];

    NSArray *correctMessages = @[
            next(210, @2),
            error(220, testError())
    ];
    XCTAssertEqualObjects(res.events, correctMessages);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 220)]);
}

@end


