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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable distinctUntilChangedWithKeySelector:^id(id o) { return o; }]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable distinctUntilChangedWithKeySelector:^id(id o) { return o; }]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable distinctUntilChangedWithComparer:^BOOL(id lhs, id rhs) { return YES; }]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable distinctUntilChangedWithComparer:^BOOL(id lhs, id rhs) { return NO; }]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable distinctUntilChangedWithKeySelector:^NSNumber *(NSNumber *o) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable distinctUntilChangedWithKeySelector:^NSNumber *(NSNumber *o) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable distinctUntilChanged:^id(id o) {
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

@implementation RxObservableSingleTest (DoOn)

- (void)testDoOn_shouldSeeAllValues {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ]];

    __block NSInteger i = 0;
    __block NSInteger sum = 2 + 3 + 4 + 5;
    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable doOn:^(RxEvent<NSNumber *> *event) {
        if (event.isNext) {
            i++;
            sum -= (event.element ? event.element.integerValue : 0);
        }
    }]];
    
    XCTAssertEqual(i, 4);
    XCTAssertEqual(sum, 0);

    NSArray *events = @[
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 250)]);
}

- (void)testDoOn_plainAction {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ]];

    __block NSInteger i = 0;
    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable doOn:^(RxEvent<NSNumber *> *event) {
        if (event.isNext) {
            i++;
        }
    }]];

    XCTAssertEqual(i, 4);

    NSArray *events = @[
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 250)]);
}

- (void)testDoOn_nextCompleted {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ]];

    __block NSInteger i = 0;
    __block NSInteger sum = 2 + 3 + 4 + 5;
    __block BOOL completedEvaluation = NO;
    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable doOn:^(RxEvent<NSNumber *> *event) {
        if (event.isNext) {
            i++;
            sum -= (event.element ? event.element.integerValue : 0);
        }
        if (event.isCompleted) {
            completedEvaluation = YES;
        }
    }]];

    XCTAssertEqual(i, 4);
    XCTAssertEqual(sum, 0);
    XCTAssert(completedEvaluation);

    NSArray *events = @[
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 250)]);
}

- (void)testDoOn_completedNever {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
    ]];

    __block NSInteger i = 0;
    __block BOOL completedEvaluation = NO;
    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable doOn:^(RxEvent<NSNumber *> *event) {
        if (event.isNext) {
            i++;
        }
        if (event.isCompleted) {
            completedEvaluation = YES;
        }
    }]];

    XCTAssertEqual(i, 0);
    XCTAssertEqual(completedEvaluation, NO);

    NSArray *events = @[
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 1000)]);
}

- (void)testDoOn_nextError {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            error(250, testError())
    ]];

    __block NSInteger i = 0;
    __block NSInteger sum = 2 + 3 + 4 + 5;
    __block BOOL sawError = NO;
    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable doOn:^(RxEvent<NSNumber *> *event) {
        if (event.isNext) {
            i++;
            sum -= event.element.integerValue;
        }
        if (event.isError) {
            sawError = YES;
        }
    }]];

    XCTAssertEqual(i, 4);
    XCTAssertEqual(sawError, YES);

    NSArray *events = @[
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            error(250, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 250)]);
}

- (void)testDoOn_nextErrorNot {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ]];

    __block NSInteger i = 0;
    __block NSInteger sum = 2 + 3 + 4 + 5;
    __block BOOL sawError = NO;
    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable doOn:^(RxEvent<NSNumber *> *event) {
        if (event.isNext) {
            i++;
            sum -= event.element.integerValue;
        }
        if (event.isError) {
            sawError = YES;
        }
    }]];

    XCTAssertEqual(i, 4);
    XCTAssertEqual(sum, 0);
    XCTAssertEqual(sawError, NO);

    NSArray *events = @[
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 250)]);
}

- (void)testDoOn_Throws {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable doOn:^(RxEvent *event) {
        @throw testError();
    }]];
    NSArray *events = @[
            error(210, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 210)]);
}

- (void)testDoOnNext_normal {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ]];

    __block NSInteger numberOfTimesInvoked = 0;
    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable doOnNext:^(id value) {
        numberOfTimesInvoked++;
    }]];

    XCTAssertEqual(numberOfTimesInvoked, 4);

    NSArray *events = @[
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 250)]);
}

- (void)testDoOnNext_throws {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ]];

    __block NSInteger numberOfTimesInvoked = 0;
    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable doOnNext:^(id value) {
        if (numberOfTimesInvoked > 2) {
            @throw testError();
        }
        numberOfTimesInvoked++;
    }]];

    XCTAssertEqual(numberOfTimesInvoked, 3);

    NSArray *events = @[
            next(210, @2),
            next(220, @3),
            next(230, @4),
            error(240, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 240)]);
}

- (void)testDoOnError_normal {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            error(250, testError())
    ]];

    __block NSError *recordedError = nil;
    __block NSInteger numberOfTimesInvoked = 0;
    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable doOnError:^(NSError *error) {
        recordedError = error;
        numberOfTimesInvoked++;
    }]];

    NSArray *events = @[
            next(210, @2),
            error(250, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 250)]);

    XCTAssertEqualObjects(recordedError, testError());
    XCTAssertEqual(numberOfTimesInvoked, 1);
}

- (void)testDoOnError_throws {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            error(250, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable doOnError:^(NSError *error) {
        @throw testError1();
    }]];

    NSArray *events = @[
            next(210, @2),
            error(250, testError1())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 250)]);
}

- (void)testDoOnCompleted_normal {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ]];

    __block BOOL didComplete = NO;

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable doOnCompleted:^() {
        didComplete = YES;
    }]];

    NSArray *events = @[
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 250)]);

    XCTAssertEqual(didComplete, YES);
}

- (void)testDoOnCompleted_throws {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ]];


    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable doOnCompleted:^() {
        @throw testError();
    }]];

    NSArray *events = @[
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            error(250, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 250)]);
}

@end

@implementation RxObservableSingleTest (Retry)

- (void)testRetry_Basic {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            next(100, @1),
            next(150, @2),
            next(200, @3),
            completed(250) 
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable retry]];

    NSArray *events = @[
            next(300, @1),
            next(350, @2),
            next(400, @3),
            completed(450)
    ];
    XCTAssertEqualObjects(res.events, events);
    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 450)
    ]);
}

- (void)testRetry_Infinite {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            next(100, @1),
            next(150, @2),
            next(200, @3),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable retry]];

    NSArray *events = @[
            next(300, @1),
            next(350, @2),
            next(400, @3),
    ];
    XCTAssertEqualObjects(res.events, events);
    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 1000)
    ]);
}

- (void)testRetry_Observable_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            next(100, @1),
            next(150, @2),
            next(200, @3),
            error(250, testError()),
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:1100 create:^RxObservable * {
        return [xs.asObservable retry];
    }];

    NSArray *events = @[
            next(300, @1),
            next(350, @2),
            next(400, @3),
            next(550, @1),
            next(600, @2),
            next(650, @3),
            next(800, @1),
            next(850, @2),
            next(900, @3),
            next(1050, @1)
    ];
    XCTAssertEqualObjects(res.events, events);

    NSArray *sub = @[
            Subscription(200, 450),
            Subscription(450, 700),
            Subscription(700, 950),
            Subscription(950, 1100)
    ];
    XCTAssertEqualObjects(xs.subscriptions, sub);
}

- (void)testRetryCount_Basic {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            next(5, @1),
            next(10, @2),
            next(15, @3),
            error(20, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable retry:3]];

    NSArray *events = @[
            next(205, @1),
            next(210, @2),
            next(215, @3),
            next(225, @1),
            next(230, @2),
            next(235, @3),
            next(245, @1),
            next(250, @2),
            next(255, @3),
            error(260, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    NSArray *sub = @[
            Subscription(200, 220),
            Subscription(220, 240),
            Subscription(240, 260)
    ];
    XCTAssertEqualObjects(xs.subscriptions, sub);
}

- (void)testRetryCount_Dispose {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            next(5, @1),
            next(10, @2),
            next(15, @3),
            error(20, testError())
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:231 create:^RxObservable * {
        return [xs.asObservable retry:3];
    }];

    NSArray *events = @[
            next(205, @1),
            next(210, @2),
            next(215, @3),
            next(225, @1),
            next(230, @2),
    ];
    XCTAssertEqualObjects(res.events, events);

    NSArray *sub = @[
            Subscription(200, 220),
            Subscription(220, 231),
    ];
    XCTAssertEqualObjects(xs.subscriptions, sub);
}

- (void)testRetryCount_Infinite {
    // differs from rxswift test
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            next(5, @1),
            next(10, @2),
            next(15, @3),
            error(20, testError())
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:251 create:^RxObservable * {
        return [xs.asObservable retry:3];
    }];

    NSArray *events = @[
            next(205, @1),
            next(210, @2),
            next(215, @3),
            next(225, @1),
            next(230, @2),
            next(235, @3),
            next(245, @1),
            next(250, @2),
    ];
    XCTAssertEqualObjects(res.events, events);

    NSArray *sub = @[
            Subscription(200, 220),
            Subscription(220, 240),
            Subscription(240, 251),
    ];
    XCTAssertEqualObjects(xs.subscriptions, sub);
}

- (void)testRetryCount_Completed {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            next(100, @1),
            next(150, @2),
            next(200, @3),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable retry:3]];

    NSArray *events = @[
            next(300, @1),
            next(350, @2),
            next(400, @3),
            completed(450)
    ];
    XCTAssertEqualObjects(res.events, events);

    NSArray *sub = @[
            Subscription(200, 450),
    ];
    XCTAssertEqualObjects(xs.subscriptions, sub);
}

- (void)testRetry_tailRecursiveOptimizationsTest {
    __block NSInteger count = 1;
    RxObservable *sequenceSendingImmediateError = [RxObservable create:^id <RxDisposable>(RxAnyObserver<NSNumber *> *observer) {
        [observer onNext:@0];
        [observer onNext:@1];
        [observer onNext:@2];

        if (count < 2) {
            [observer onError:testError()];
            count++;
        }

        [observer onNext:@3];
        [observer onNext:@4];
        [observer onNext:@5];
        [observer onCompleted];

        return [RxNopDisposable sharedInstance];
    }];

    [[sequenceSendingImmediateError retry] subscribeWith:^(RxEvent *event) {
    }];
}

@end

@interface RxCustomTestError : NSError
@end

@implementation RxCustomTestError
@end

@implementation RxObservableSingleTest (RetryWhen)

- (void)testRetryWhen_Never {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            completed(250)
    ]];

    RxTestableObservable *empty = [scheduler createHotObservable:@[
            next(150, @1),
            completed(210)
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:300 create:^RxObservable * {
        return [xs.asObservable retryWhen:^id <RxObservableType>(RxObservable<NSError *> *observable) {
            return empty;
        }];
    }];

    NSArray *correct = @[
            completed(250)
    ];

    XCTAssertEqualObjects(res.events, correct);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 250)
    ]);
}

- (void)testRetryWhen_ObservableNever {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            error(250, testError())
    ]];

    RxTestableObservable *never = [scheduler createHotObservable:@[
            next(150, @1),
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:300 create:^RxObservable * {
        return [xs.asObservable retryWhen:^id <RxObservableType>(RxObservable<NSError *> *observable) {
            return never;
        }];
    }];

    NSArray *correct = @[
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5)
    ];

    XCTAssertEqualObjects(res.events, correct);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 250)
    ]);
}

- (void)testRetryWhen_ObservableNeverComplete {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ]];

    RxTestableObservable *never = [scheduler createHotObservable:@[
            next(150, @1),
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:300 create:^RxObservable * {
        return [xs.asObservable retryWhen:^id <RxObservableType>(RxObservable<NSError *> *observable) {
            return never;
        }];
    }];

    NSArray *correct = @[
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ];

    XCTAssertEqualObjects(res.events, correct);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 250)
    ]);
}

- (void)testRetryWhen_ObservableEmpty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            next(100, @1),
            next(150, @2),
            next(200, @3),
            completed(250)
    ]];

    RxTestableObservable *empty = [scheduler createHotObservable:@[
            next(150, @1),
            completed(0),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable retryWhen:^id <RxObservableType>(RxObservable<NSError *> *observable) {
        return empty;
    }]];

    NSArray *correct = @[
            next(300, @1),
            next(350, @2),
            next(400, @3),
            completed(450)
    ];

    XCTAssertEqualObjects(res.events, correct);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 450)
    ]);
}

- (void)testRetryWhen_ObservableNextError {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            next(10, @1),
            next(20, @2),
            error(30, testError()),
            completed(40)
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:300 create:^RxObservable * {
        return [xs.asObservable retryWhen:^id <RxObservableType>(RxObservable<NSError *> *errors) {
            return [errors scan:@0 accumulator:^NSNumber *(NSNumber *_a, NSError *_e) {
                NSInteger a = _a.integerValue;
                a++;
                if (a == 2) {
                    @throw testError1();
                }
                return @(a);
            }];
            return nil;
        }];
    }];

    NSArray *correct = @[
            next(210, @1),
            next(220, @2),
            next(240, @1),
            next(250, @2),
            error(260, testError1())
    ];

    XCTAssertEqualObjects(res.events, correct);

    NSArray *sub = @[
            Subscription(200, 230),
            Subscription(230, 260)
    ];
    XCTAssertEqualObjects(xs.subscriptions, sub);
}

- (void)testRetryWhen_ObservableComplete {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            next(10, @1),
            next(20, @2),
            error(30, testError()),
            completed(40)
    ]];

    RxTestableObservable *empty = [scheduler createHotObservable:@[
            next(150, @1),
            completed(230)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable retryWhen:^id <RxObservableType>(RxObservable<NSError *> *observable) {
        return [empty asObservable];
    }]];

    NSArray *correct = @[
            next(210, @1),
            next(220, @2),
            completed(230)
    ];

    XCTAssertEqualObjects(res.events, correct);

    NSArray *sub = @[
            Subscription(200, 230),
    ];
    XCTAssertEqualObjects(xs.subscriptions, sub);
}

- (void)testRetryWhen_ObservableNextComplete {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            next(10, @1),
            next(20, @2),
            error(30, testError()),
            completed(40)
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:300 create:^RxObservable * {
        return [xs.asObservable retryWhen:^id <RxObservableType>(RxObservable<NSError *> *errors) {
            return [[errors scan:@0 accumulator:^NSNumber *(NSNumber *accumulate, NSError *element) {
                return @(accumulate.integerValue + 1);
            }] takeWhile:^BOOL(NSNumber *num) {
                return num.integerValue < 2;
            }];
        }];
    }];

    NSArray *correct = @[
            next(210, @1),
            next(220, @2),
            next(240, @1),
            next(250, @2),
            completed(260)
    ];

    XCTAssertEqualObjects(res.events, correct);

    NSArray *sub = @[
            Subscription(200, 230),
            Subscription(230, 260)
    ];
    XCTAssertEqualObjects(xs.subscriptions, sub);
}

- (void)testRetryWhen_ObservableInfinite {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            next(10, @1),
            next(20, @2),
            error(30, testError()),
            completed(40)
    ]];

    RxTestableObservable *never = [scheduler createHotObservable:@[
            next(150, @1),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable retryWhen:^id <RxObservableType>(RxObservable<NSError *> *observable) {
        return never;
    }]];

    NSArray *correct = @[
            next(210, @1),
            next(220, @2)
    ];

    XCTAssertEqualObjects(res.events, correct);

    NSArray *sub = @[
            Subscription(200, 230)
    ];
    XCTAssertEqualObjects(xs.subscriptions, sub);
}

- (void)testRetryWhen_Incremental_BackOff {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    // just fails
    RxTestableObservable *xs = [scheduler createColdObservable:@[
            next(5, @1),
            error(10, testError())
    ]];

    __block NSInteger maxAttempts = 4;

    RxTestableObserver *res = [scheduler startWhenDisposed:800 create:^RxObservable * {
        return [xs.asObservable retryWhen:^id <RxObservableType>(RxObservable<NSError *> *errors) {
            return [errors flatMapWithIndex:^id <RxObservableConvertibleType>(NSError *element, NSUInteger index) {
                if (index >= maxAttempts - 1) {
                    return [RxObservable error:element];
                }
                return [RxObservable timer:(index + 1) * 50 scheduler:scheduler];
            }];
        }];
    }];


    NSArray *correct = @[
            next(205, @1),
            next(265, @1),
            next(375, @1),
            next(535, @1),
            error(540, testError())
    ];

    XCTAssertEqualObjects(res.events, correct);

    NSArray *sub = @[
            Subscription(200, 210),
            Subscription(260, 270),
            Subscription(370, 380),
            Subscription(530, 540)
    ];
    XCTAssertEqualObjects(xs.subscriptions, sub);
}

- (void)testRetryWhen_IgnoresDifferentErrorTypes {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    // just fails
    RxTestableObservable *xs = [scheduler createColdObservable:@[
            next(5, @1),
            error(10, testError())
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:800 create:^RxObservable * {
        return [xs.asObservable retryWhen:^id <RxObservableType>(RxObservable<NSError *> *errors) {
            return errors;
        } customErrorClass:[RxCustomTestError class]];
    }];

    NSArray *correct = @[
            next(205, @1),
            error(210, testError())
    ];

    XCTAssertEqualObjects(res.events, correct);

    NSArray *sub = @[
            Subscription(200, 210),
    ];
    XCTAssertEqualObjects(xs.subscriptions, sub);
}

- (void)testRetryWhen_tailRecursiveOptimizationsTest {
    __block NSInteger count = 1;
    RxObservable *sequenceSendingImmediateError = [RxObservable create:^id <RxDisposable>(RxAnyObserver *observer) {
        [observer onNext:@0];
        [observer onNext:@1];
        [observer onNext:@2];

        if (count < 2) {
            [observer onError:testError()];
            count++;
        }

        [observer onNext:@3];
        [observer onNext:@4];
        [observer onNext:@5];
        [observer onCompleted];

        return [RxNopDisposable sharedInstance];
    }];

    [[sequenceSendingImmediateError retryWhen:^id <RxObservableType>(RxObservable<__kindof NSError *> *observable) {
        return observable;
    }] subscribeWith:^(RxEvent *event) {

    }];
}

@end

@implementation RxObservableSingleTest (Scan)

- (void)testScan_Seed_Never {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(0, @0),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable scan:@42 accumulator:RxCombinePlus()]];

    NSArray *correct = @[
    ];

    XCTAssertEqualObjects(res.events, correct);

    NSArray *sub = @[
            Subscription(200, 1000),
    ];
    XCTAssertEqualObjects(xs.subscriptions, sub);
}

- (void)testScan_Seed_Empty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable scan:@42 accumulator:RxCombinePlus()]];

    NSArray *correct = @[
            completed(250)
    ];

    XCTAssertEqualObjects(res.events, correct);

    NSArray *sub = @[
            Subscription(200, 250)
    ];
    XCTAssertEqualObjects(xs.subscriptions, sub);
}

- (void)testScan_Seed_Return {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(220, @2),
            completed(250)
    ]];

    NSNumber *seed = @42;
    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable scan:seed accumulator:RxCombinePlus()]];

    NSArray *correct = @[
            next(220, @(seed.integerValue + 2)),
            completed(250)
    ];

    XCTAssertEqualObjects(res.events, correct);

    NSArray *sub = @[
            Subscription(200, 250)
    ];
    XCTAssertEqualObjects(xs.subscriptions, sub);
}

- (void)testScan_Seed_Throw {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            error(250, testError())
    ]];

    NSNumber *seed = @42;
    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable scan:seed accumulator:RxCombinePlus()]];

    NSArray *correct = @[
            error(250, testError())
    ];

    XCTAssertEqualObjects(res.events, correct);

    NSArray *sub = @[
            Subscription(200, 250)
    ];
    XCTAssertEqualObjects(xs.subscriptions, sub);
}

- (void)testScan_Seed_SomeData {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ]];

    NSNumber *seed = @42;
    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable scan:seed accumulator:RxCombinePlus()]];

    NSArray *correct = @[
            next(210, @(seed.integerValue + 2)),
            next(220, @(seed.integerValue + 2 + 3)),
            next(230, @(seed.integerValue + 2 + 3 + 4)),
            next(240, @(seed.integerValue + 2 + 3 + 4 + 5)),
            completed(250)
    ];

    XCTAssertEqualObjects(res.events, correct);

    NSArray *sub = @[
            Subscription(200, 250)
    ];
    XCTAssertEqualObjects(xs.subscriptions, sub);
}

- (void)testScan_Seed_AccumulatorThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ]];

    NSNumber *seed = @42;
    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable scan:seed accumulator:^NSNumber *(NSNumber *accumulate, NSNumber *element) {
        if (element.integerValue == 4) {
            @throw testError();
        } else {
            return @(accumulate.integerValue + element.integerValue);
        }
    }]];

    NSArray *correct = @[
            next(210, @(seed.integerValue + 2)),
            next(220, @(seed.integerValue + 2 + 3)),
            error(230, testError())
    ];

    XCTAssertEqualObjects(res.events, correct);

    NSArray *sub = @[
            Subscription(200, 230)
    ];
    XCTAssertEqualObjects(xs.subscriptions, sub);
}

@end


