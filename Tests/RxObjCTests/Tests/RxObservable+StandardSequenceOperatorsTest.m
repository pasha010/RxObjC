//
//  RxObservable+StandardSequenceOperatorsTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 10.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"
#import "RxElementIndexPair.h"

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCDFAInspection"

BOOL isPrime(NSNumber *n) {
    NSInteger i = n.integerValue;
    if (i <= 1) {
        return NO;
    }

    NSInteger max = (NSInteger) sqrt(((double) i));
    if (max <= 1) {
        return YES;
    }

    for (NSUInteger j = 2; j <= max; j++) {
        if (i % j == 0) {
            return NO;
        }
    }
    return YES;
}

@interface RxObservableStandardSequenceOperatorsTest : RxTest
@end

@implementation RxObservableStandardSequenceOperatorsTest
@end

@implementation RxObservableStandardSequenceOperatorsTest (Where)

- (void)test_filterComplete {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block NSInteger invoked = 0;

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(110, @1),
            next(180, @2),
            next(230, @3),
            next(270, @4),
            next(340, @5),
            next(380, @6),
            next(390, @7),
            next(450, @8),
            next(470, @9),
            next(560, @10),
            next(580, @11),
            completed(600),
            next(610, @12),
            error(620, testError()),
            completed(630)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs filter:^BOOL(NSNumber *n) {
        invoked++;
        return isPrime(n);
    }]];

    NSArray *events = @[
            next(230, @3),
            next(340, @5),
            next(390, @7),
            next(580, @11),
            completed(600)   
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 600)
    ]);

    XCTAssertEqual(invoked, 9);
}

- (void)test_filterTrue {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block NSInteger invoked = 0;

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(110, @1),
            next(180, @2),
            next(230, @3),
            next(270, @4),
            next(340, @5),
            next(380, @6),
            next(390, @7),
            next(450, @8),
            next(470, @9),
            next(560, @10),
            next(580, @11),
            completed(600)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs filter:^BOOL(NSNumber *n) {
        invoked++;
        return YES;
    }]];

    NSArray *events = @[
            next(230, @3),
            next(270, @4),
            next(340, @5),
            next(380, @6),
            next(390, @7),
            next(450, @8),
            next(470, @9),
            next(560, @10),
            next(580, @11),
            completed(600)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 600)
    ]);

    XCTAssertEqual(invoked, 9);
}

- (void)test_filterFalse {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block NSInteger invoked = 0;

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(110, @1),
            next(180, @2),
            next(230, @3),
            next(270, @4),
            next(340, @5),
            next(380, @6),
            next(390, @7),
            next(450, @8),
            next(470, @9),
            next(560, @10),
            next(580, @11),
            completed(600)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs filter:^BOOL(NSNumber *n) {
        invoked++;
        return NO;
    }]];

    NSArray *events = @[
            completed(600)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 600)
    ]);

    XCTAssertEqual(invoked, 9);
}

- (void)test_filterDisposed {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block NSInteger invoked = 0;

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(110, @1),
            next(180, @2),
            next(230, @3),
            next(270, @4),
            next(340, @5),
            next(380, @6),
            next(390, @7),
            next(450, @8),
            next(470, @9),
            next(560, @10),
            next(580, @11),
            completed(600)
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:400 create:^RxObservable * {
        return [xs filter:^BOOL(NSNumber *n) {
            invoked++;
            return isPrime(n);
        }];
    }];

    NSArray *events = @[
            next(230, @3),
            next(340, @5),
            next(390, @7)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 400)
    ]);

    XCTAssertEqual(invoked, 5);
}

@end

@implementation RxObservableStandardSequenceOperatorsTest (TakeWhile)

- (void)testTakeWhile_Complete_Before {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90, @(-1)),
            next(110, @(-1)),
            next(210, @2),
            next(260, @5),
            next(290, @13),
            next(320, @3),
            completed(330),
            next(350, @7),
            next(390, @4),
            next(410, @17),
            next(450, @8),
            next(500, @23),
            completed(600)
    ]];

    __block NSInteger invoked = 0;

    RxTestableObserver *res = [scheduler startWithObservable:[xs takeWhile:^BOOL(NSNumber *n) {
        invoked++;
        return isPrime(n);
    }]];

    NSArray *events = @[
            next(210, @2),
            next(260, @5),
            next(290, @13),
            next(320, @3),
            completed(330)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 330)
    ]);

    XCTAssertEqual(invoked, 4);
}

- (void)testTakeWhile_Complete_After {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90, @(-1)),
            next(110, @(-1)),
            next(210, @2),
            next(260, @5),
            next(290, @13),
            next(320, @3),
            next(350, @7),
            next(390, @4),
            next(410, @17),
            next(450, @8),
            next(500, @23),
            completed(600)
    ]];

    __block NSInteger invoked = 0;

    RxTestableObserver *res = [scheduler startWithObservable:[xs takeWhile:^BOOL(NSNumber *n) {
        invoked++;
        return isPrime(n);
    }]];

    NSArray *events = @[
            next(210, @2),
            next(260, @5),
            next(290, @13),
            next(320, @3),
            next(350, @7),
            completed(390)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 390)
    ]);

    XCTAssertEqual(invoked, 6);
}

- (void)testTakeWhile_Error_Before {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90, @(-1)),
            next(110, @(-1)),
            next(210, @2),
            next(260, @5),
            error(270, testError()),
            next(290, @13),
            next(320, @3),
            next(350, @7),
            next(390, @4),
            next(410, @17),
            next(450, @8),
            next(500, @23),
            completed(600)
    ]];

    __block NSInteger invoked = 0;

    RxTestableObserver *res = [scheduler startWithObservable:[xs takeWhile:^BOOL(NSNumber *n) {
        invoked++;
        return isPrime(n);
    }]];

    NSArray *events = @[
            next(210, @2),
            next(260, @5),
            error(270, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 270)
    ]);

    XCTAssertEqual(invoked, 2);
}

- (void)testTakeWhile_Error_After {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90, @(-1)),
            next(110, @(-1)),
            next(210, @2),
            next(260, @5),
            next(290, @13),
            next(320, @3),
            next(350, @7),
            next(390, @4),
            next(410, @17),
            next(450, @8),
            next(500, @23),
            error(600, testError()),
    ]];

    __block NSInteger invoked = 0;

    RxTestableObserver *res = [scheduler startWithObservable:[xs takeWhile:^BOOL(NSNumber *n) {
        invoked++;
        return isPrime(n);
    }]];

    NSArray *events = @[
            next(210, @2),
            next(260, @5),
            next(290, @13),
            next(320, @3),
            next(350, @7),
            completed(390)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 390)
    ]);

    XCTAssertEqual(invoked, 6);
}

- (void)testTakeWhile_Dispose_Before {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90, @(-1)),
            next(110, @(-1)),
            next(210, @2),
            next(260, @5),
            next(290, @13),
            next(320, @3),
            next(350, @7),
            next(390, @4),
            next(410, @17),
            next(450, @8),
            next(500, @23),
            error(600, testError()),
    ]];

    __block NSInteger invoked = 0;

    RxTestableObserver *res = [scheduler startWhenDisposed:300 create:^RxObservable * {
        return [xs takeWhile:^BOOL(NSNumber *n) {
            invoked++;
            return isPrime(n);
        }];
    }];

    NSArray *events = @[
            next(210, @2),
            next(260, @5),
            next(290, @13)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 300)
    ]);

    XCTAssertEqual(invoked, 3);
}

- (void)testTakeWhile_Dispose_After {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90, @(-1)),
            next(110, @(-1)),
            next(210, @2),
            next(260, @5),
            next(290, @13),
            next(320, @3),
            next(350, @7),
            next(390, @4),
            next(410, @17),
            next(450, @8),
            next(500, @23),
            error(600, testError()),
    ]];

    __block NSInteger invoked = 0;

    RxTestableObserver *res = [scheduler startWhenDisposed:400 create:^RxObservable * {
        return [xs takeWhile:^BOOL(NSNumber *n) {
            invoked++;
            return isPrime(n);
        }];
    }];

    NSArray *events = @[
            next(210, @2),
            next(260, @5),
            next(290, @13),
            next(320, @3),
            next(350, @7),
            completed(390)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 390)
    ]);

    XCTAssertEqual(invoked, 6);
}

- (void)testTakeWhile_Zero {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90, @(-1)),
            next(110, @(-1)),
            next(205, @100),
            next(210, @2),
            next(260, @5),
            next(290, @13),
            next(320, @3),
            next(350, @7),
            next(390, @4),
            next(410, @17),
            next(450, @8),
            next(500, @23),
            error(600, testError()),
    ]];

    __block NSInteger invoked = 0;

    RxTestableObserver *res = [scheduler startWhenDisposed:300 create:^RxObservable * {
        return [xs takeWhile:^BOOL(NSNumber *n) {
            invoked++;
            return isPrime(n);
        }];
    }];

    NSArray *events = @[
            completed(205)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 205)
    ]);

    XCTAssertEqual(invoked, 1);
}

- (void)testTakeWhile_Throw {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90, @(-1)),
            next(110, @(-1)),
            next(210, @2),
            next(260, @5),
            next(290, @13),
            next(320, @3),
            next(350, @7),
            next(390, @4),
            next(410, @17),
            next(450, @8),
            next(500, @23),
            completed(600),
    ]];

    __block NSInteger invoked = 0;

    RxTestableObserver *res = [scheduler startWhenDisposed:300 create:^RxObservable * {
        return [xs takeWhile:^BOOL(NSNumber *n) {
            invoked++;
            if (invoked == 3) {
                @throw testError();
            }
            return isPrime(n);
        }];
    }];

    NSArray *events = @[
            next(210, @2),
            next(260, @5),
            error(290, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 290)
    ]);

    XCTAssertEqual(invoked, 3);
}

- (void)testTakeWhile_Index1 {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90, @(-1)),
            next(110, @(-1)),
            next(205, @100),
            next(210, @2),
            next(260, @5),
            next(290, @13),
            next(320, @3),
            next(350, @7),
            next(390, @4),
            next(410, @17),
            next(450, @8),
            next(500, @23),
            error(600, testError()),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs takeWhileWithIndex:^BOOL(NSNumber *num, NSUInteger index) {
        return index < 5;
    }]];

    NSArray *events = @[
            next(205, @100),
            next(210, @2),
            next(260, @5),
            next(290, @13),
            next(320, @3),
            completed(350)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 350)
    ]);
}

- (void)testTakeWhile_Index2 {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90, @(-1)),
            next(110, @(-1)),
            next(205, @100),
            next(210, @2),
            next(260, @5),
            next(290, @13),
            next(320, @3),
            next(350, @7),
            next(390, @4),
            completed(400),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs takeWhileWithIndex:^BOOL(NSNumber *num, NSUInteger index) {
        return YES;
    }]];

    NSArray *events = @[
            next(205, @100),
            next(210, @2),
            next(260, @5),
            next(290, @13),
            next(320, @3),
            next(350, @7),
            next(390, @4),
            completed(400)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 400)
    ]);
}

- (void)testTakeWhile_Index_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90, @(-1)),
            next(110, @(-1)),
            next(205, @100),
            next(210, @2),
            next(260, @5),
            next(290, @13),
            next(320, @3),
            next(350, @7),
            next(390, @4),
            error(400, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs takeWhileWithIndex:^BOOL(NSNumber *num, NSUInteger index) {
        return YES;
    }]];

    NSArray *events = @[
            next(205, @100),
            next(210, @2),
            next(260, @5),
            next(290, @13),
            next(320, @3),
            next(350, @7),
            next(390, @4),
            error(400, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 400)
    ]);
}

- (void)testTakeWhile_Index_SelectorThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90, @(-1)),
            next(110, @(-1)),
            next(205, @100),
            next(210, @2),
            next(260, @5),
            next(290, @13),
            next(320, @3),
            next(350, @7),
            next(390, @4),
            completed(400),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs takeWhileWithIndex:^BOOL(NSNumber *num, NSUInteger index) {
        if (index < 5) {
            return YES;
        }
        @throw testError();
    }]];

    NSArray *events = @[
            next(205, @100),
            next(210, @2),
            next(260, @5),
            next(290, @13),
            next(320, @3),
            error(350, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 350)
    ]);
}

@end

@implementation RxObservableStandardSequenceOperatorsTest (Map)

- (void)testMap_Never {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    
    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs map:^NSNumber *(NSNumber *o) {
        return @(o.integerValue * 2);
    }]];

    NSArray *events = @[
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 1000)
    ]);
}

- (void)testMap_Empty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            completed(300),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs map:^NSNumber *(NSNumber *o) {
        return @(o.integerValue * 2);
    }]];

    NSArray *events = @[
            completed(300),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 300)
    ]);
}

- (void)testMap_Range {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @0),
            next(220, @1),
            next(230, @2),
            next(240, @4),
            completed(300)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs map:^NSNumber *(NSNumber *o) {
        return @(o.integerValue * 2);
    }]];

    NSArray *events = @[
            next(210, @(0 * 2)),
            next(220, @(1 * 2)),
            next(230, @(2 * 2)),
            next(240, @(4 * 2)),
            completed(300),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 300)
    ]);
}

- (void)testMap_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @0),
            next(220, @1),
            next(230, @2),
            next(240, @4),
            error(300, testError()),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs map:^NSNumber *(NSNumber *o) {
        return @(o.integerValue * 2);
    }]];

    NSArray *events = @[
            next(210, @(0 * 2)),
            next(220, @(1 * 2)),
            next(230, @(2 * 2)),
            next(240, @(4 * 2)),
            error(300, testError()),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 300)
    ]);
}

- (void)testMap_Dispose {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @0),
            next(220, @1),
            next(230, @2),
            next(240, @4),
            error(300, testError()),
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:290 create:^RxObservable * {
        return [xs map:^NSNumber *(NSNumber *o) {
            return @(o.integerValue * 2);
        }];
    }];

    NSArray *events = @[
            next(210, @(0 * 2)),
            next(220, @(1 * 2)),
            next(230, @(2 * 2)),
            next(240, @(4 * 2)),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 290)
    ]);
}

- (void)testMap_SelectorThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @0),
            next(220, @1),
            next(230, @2),
            next(240, @4),
            error(300, testError1()),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs map:^NSNumber *(NSNumber *o) {
        if (o.integerValue < 2) {
            return @(o.integerValue * 2);
        }
        @throw testError();
    }]];

    NSArray *events = @[
            next(210, @(0 * 2)),
            next(220, @(1 * 2)),
            error(230, testError()),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 230)
    ]);
}

- (void)testMap1_Never {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs mapWithIndex:^NSNumber *(NSNumber *element, NSInteger index) {
        return @((element.integerValue + index) * 2);
    }]];

    NSArray *events = @[
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 1000)
    ]);
}

- (void)testMap1_Empty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            completed(300),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs mapWithIndex:^NSNumber *(NSNumber *element, NSInteger index) {
        return @((element.integerValue + index) * 2);
    }]];

    NSArray *events = @[
            completed(300),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 300)
    ]);
}

- (void)testMap1_Range {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @5),
            next(220, @6),
            next(230, @7),
            next(240, @8),
            completed(300)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs mapWithIndex:^NSNumber *(NSNumber *element, NSInteger index) {
        return @((element.integerValue + index) * 2);
    }]];

    NSArray *events = @[
            next(210, @((5 + 0) * 2)),
            next(220, @((6 + 1) * 2)),
            next(230, @((7 + 2) * 2)),
            next(240, @((8 + 3) * 2)),
            completed(300),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 300)
    ]);
}

- (void)testMap1_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @5),
            next(220, @6),
            next(230, @7),
            next(240, @8),
            error(300, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs mapWithIndex:^NSNumber *(NSNumber *element, NSInteger index) {
        return @((element.integerValue + index) * 2);
    }]];

    NSArray *events = @[
            next(210, @((5 + 0) * 2)),
            next(220, @((6 + 1) * 2)),
            next(230, @((7 + 2) * 2)),
            next(240, @((8 + 3) * 2)),
            error(300, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 300)
    ]);
}

- (void)testMap1_Dispose {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @5),
            next(220, @6),
            next(230, @7),
            next(240, @8),
            error(300, testError())
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:290 create:^RxObservable * {
        return [xs mapWithIndex:^NSNumber *(NSNumber *element, NSInteger index) {
            return @((element.integerValue + index) * 2);
        }];
    }];

    NSArray *events = @[
            next(210, @((5 + 0) * 2)),
            next(220, @((6 + 1) * 2)),
            next(230, @((7 + 2) * 2)),
            next(240, @((8 + 3) * 2)),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 290)
    ]);
}

- (void)testMap1_SelectorThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @5),
            next(220, @6),
            next(230, @7),
            next(240, @8),
            error(300, testError1())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs mapWithIndex:^NSNumber *(NSNumber *element, NSInteger index) {
        if (element.integerValue < 7) {
            return @((element.integerValue + index) * 2);
        }
        @throw testError();
    }]];

    NSArray *events = @[
            next(210, @((5 + 0) * 2)),
            next(220, @((6 + 1) * 2)),
            error(230, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 230)
    ]);
}

- (void)testMap_DisposeOnCompleted {
    [[[RxObservable just:@"A"] mapWithIndex:^id(id element, NSInteger index) {
        return element;
    }] subscribeNext:^(id o) {

    }];
}

@end

@implementation RxObservableStandardSequenceOperatorsTest (MapCompose)

- (void)testMapCompose_Never {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[[xs map:^NSNumber *(NSNumber *element) {
        return @(element.integerValue * 10);
    }] map:^NSNumber *(NSNumber *element) {
        return @(element.integerValue + 1);
    }]];

    NSArray *events = @[
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 1000)
    ]);
}

- (void)testMapCompose_Empty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            completed(300)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[[xs map:^NSNumber *(NSNumber *element) {
        return @(element.integerValue * 10);
    }] map:^NSNumber *(NSNumber *element) {
        return @(element.integerValue + 1);
    }]];

    NSArray *events = @[
            completed(300)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 300)
    ]);
}

- (void)testMapCompose_Range {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @0),
            next(220, @1),
            next(230, @2),
            next(240, @4),
            completed(300)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[[xs map:^NSNumber *(NSNumber *element) {
        return @(element.integerValue * 10);
    }] map:^NSNumber *(NSNumber *element) {
        return @(element.integerValue + 1);
    }]];

    NSArray *events = @[
            next(210, @(0 * 10 + 1)),
            next(220, @(1 * 10 + 1)),
            next(230, @(2 * 10 + 1)),
            next(240, @(4 * 10 + 1)),
            completed(300),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 300)
    ]);
}

- (void)testMapCompose_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @0),
            next(220, @1),
            next(230, @2),
            next(240, @4),
            error(300, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[[xs map:^NSNumber *(NSNumber *element) {
        return @(element.integerValue * 10);
    }] map:^NSNumber *(NSNumber *element) {
        return @(element.integerValue + 1);
    }]];

    NSArray *events = @[
            next(210, @(0 * 10 + 1)),
            next(220, @(1 * 10 + 1)),
            next(230, @(2 * 10 + 1)),
            next(240, @(4 * 10 + 1)),
            error(300, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 300)
    ]);
}

- (void)testMapCompose_Dispose {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @0),
            next(220, @1),
            next(230, @2),
            next(240, @4),
            error(300, testError())
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:290 create:^RxObservable * {
        return [[xs map:^NSNumber *(NSNumber *element) {
            return @(element.integerValue * 10);
        }] map:^NSNumber *(NSNumber *element) {
            return @(element.integerValue + 1);
        }];
    }];

    NSArray *events = @[
            next(210, @(0 * 10 + 1)),
            next(220, @(1 * 10 + 1)),
            next(230, @(2 * 10 + 1)),
            next(240, @(4 * 10 + 1)),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 290)
    ]);
}

- (void)testMapCompose_Selector1Throws {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @0),
            next(220, @1),
            next(230, @2),
            next(240, @4),
            error(300, testError1())
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:290 create:^RxObservable * {
        return [[xs map:^NSNumber *(NSNumber *element) {
            if (element.integerValue < 2) {
                return @(element.integerValue * 10);
            }
            @throw testError();
        }] map:^NSNumber *(NSNumber *element) {
            return @(element.integerValue + 1);
        }];
    }];

    NSArray *events = @[
            next(210, @(0 * 10 + 1)),
            next(220, @(1 * 10 + 1)),
            error(230, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 230)
    ]);
}

- (void)testMapCompose_Selector2Throws {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @0),
            next(220, @1),
            next(230, @2),
            next(240, @4),
            error(300, testError1())
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:290 create:^RxObservable * {
        return [[xs map:^NSNumber *(NSNumber *element) {
            return @(element.integerValue * 10);
        }] map:^NSNumber *(NSNumber *element) {
            if (element.integerValue < 20) {
                return @(element.integerValue + 1);
            }
            @throw testError();
        }];
    }];

    NSArray *events = @[
            next(210, @(0 * 10 + 1)),
            next(220, @(1 * 10 + 1)),
            error(230, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 230)
    ]);
}

#if TRACE_RESOURCES
- (void)testMapCompose_OptimizationIsPerformed {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block BOOL checked = NO;
    
    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @0),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[[xs map:^NSNumber *(NSNumber *element) {
        XCTAssertEqual(rx_numberOfMapOperators, 2);
        return @(element.integerValue * 10);
    }] map:^NSNumber *(NSNumber *element) {
        checked = YES;
        XCTAssertEqual(rx_numberOfMapOperators, 2);
        return @(element.integerValue + 1);
    }]];

    NSArray *events = @[
            next(210, @(0 * 10 + 1)),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 1000)
    ]);

    XCTAssertTrue(checked);
}

- (void)testMapCompose_OptimizationIsNotPerformed {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block BOOL checked = NO;

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @0),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[[[xs map:^NSNumber *(NSNumber *element) {
        return @(element.integerValue * 10);
    }] filter:^BOOL(id o) {
        return YES;
    }] map:^NSNumber *(NSNumber *element) {
        checked = YES;
        XCTAssertEqual(rx_numberOfMapOperators, 2);
        return @(element.integerValue + 1);
    }]];

    NSArray *events = @[
            next(210, @(0 * 10 + 1)),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 1000)
    ]);

    XCTAssertTrue(checked);
}
#endif

@end

@implementation RxObservableStandardSequenceOperatorsTest (FlatMapFirst)

- (void)testFlatMapFirst_Complete {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable<RxTestableObservable<NSNumber *> *> *xs = [scheduler createHotObservable:@[
            next(5, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(105, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(300, [scheduler createColdObservable:@[
                    next(10, @102),
                    next(90, @103),
                    next(110, @104),
                    next(190, @105),
                    next(440, @106),
                    completed(460)
            ]]),
            next(400, [scheduler createColdObservable:@[
                    next(180, @202),
                    next(190, @203),
                    completed(205)
            ]]),
            next(550, [scheduler createColdObservable:@[
                    next(10, @301),
                    next(50, @302),
                    next(70, @303),
                    next(260, @304),
                    next(310, @305),
                    completed(410)
            ]]),
            next(750, [scheduler createColdObservable:@[
                    completed(40)
            ]]),
            next(850, [scheduler createColdObservable:@[
                    next(80, @401),
                    next(90, @402),
                    completed(100)
            ]]),
            completed(900)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs flatMapFirst:^id <RxObservableConvertibleType>(id element) {
        return element;
    }]];

    NSArray *events = @[
            next(310, @102),
            next(390, @103),
            next(410, @104),
            next(490, @105),
            next(740, @106),
            next(930, @401),
            next(940, @402),
            completed(950)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 900)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[2].value.element.subscriptions, @[
            Subscription(300, 760)
    ]);
    XCTAssertEqualObjects(xs.recordedEvents[3].value.element.subscriptions, @[]);
    XCTAssertEqualObjects(xs.recordedEvents[4].value.element.subscriptions, @[]);
    XCTAssertEqualObjects(xs.recordedEvents[5].value.element.subscriptions, @[]);
    XCTAssertEqualObjects(xs.recordedEvents[6].value.element.subscriptions, @[
            Subscription(850, 950)
    ]);

}

- (void)testFlatMapFirst_Complete_InnerNotComplete {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable<RxTestableObservable<NSNumber *> *> *xs = [scheduler createHotObservable:@[
            next(5, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(105, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(300, [scheduler createColdObservable:@[
                    next(10, @102),
                    next(90, @103),
                    next(110, @104),
                    next(190, @105),
                    next(440, @106),
                    completed(460)
            ]]),
            next(400, [scheduler createColdObservable:@[
                    next(180, @202),
                    next(190, @203),
                    completed(205)
            ]]),
            next(550, [scheduler createColdObservable:@[
                    next(10, @301),
                    next(50, @302),
                    next(70, @303),
                    next(260, @304),
                    next(310, @305),
                    completed(410)
            ]]),
            next(750, [scheduler createColdObservable:@[
                    completed(40)
            ]]),
            next(850, [scheduler createColdObservable:@[
                    next(80, @401),
                    next(90, @402),
                    completed(100)
            ]]),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs flatMapFirst:^id <RxObservableConvertibleType>(id element) {
        return element;
    }]];

    NSArray *events = @[
            next(310, @102),
            next(390, @103),
            next(410, @104),
            next(490, @105),
            next(740, @106),
            next(930, @401),
            next(940, @402),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 1000)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[2].value.element.subscriptions, @[
            Subscription(300, 760)
    ]);
    XCTAssertEqualObjects(xs.recordedEvents[3].value.element.subscriptions, @[]);
    XCTAssertEqualObjects(xs.recordedEvents[4].value.element.subscriptions, @[]);
    XCTAssertEqualObjects(xs.recordedEvents[5].value.element.subscriptions, @[]);
    XCTAssertEqualObjects(xs.recordedEvents[6].value.element.subscriptions, @[
            Subscription(850, 950)
    ]);
}

- (void)testFlatMapFirst_Complete_OuterNotComplete {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable<RxTestableObservable<NSNumber *> *> *xs = [scheduler createHotObservable:@[
            next(5, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(105, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(300, [scheduler createColdObservable:@[
                    next(10, @102),
                    next(90, @103),
                    next(110, @104),
                    next(190, @105),
                    next(440, @106),
                    completed(460)
            ]]),
            next(400, [scheduler createColdObservable:@[
                    next(180, @202),
                    next(190, @203),
            ]]),
            next(550, [scheduler createColdObservable:@[
                    next(10, @301),
                    next(50, @302),
                    next(70, @303),
                    next(260, @304),
                    next(310, @305),
                    completed(410)
            ]]),
            next(750, [scheduler createColdObservable:@[
                    completed(40)
            ]]),
            next(850, [scheduler createColdObservable:@[
                    next(80, @401),
                    next(90, @402),
                    completed(100)
            ]]),
            completed(900)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs flatMapFirst:^id <RxObservableConvertibleType>(id element) {
        return element;
    }]];

    NSArray *events = @[
            next(310, @102),
            next(390, @103),
            next(410, @104),
            next(490, @105),
            next(740, @106),
            next(930, @401),
            next(940, @402),
            completed(950),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 900)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[2].value.element.subscriptions, @[
            Subscription(300, 760)
    ]);
    XCTAssertEqualObjects(xs.recordedEvents[3].value.element.subscriptions, @[]);
    XCTAssertEqualObjects(xs.recordedEvents[4].value.element.subscriptions, @[]);
    XCTAssertEqualObjects(xs.recordedEvents[5].value.element.subscriptions, @[]);
    XCTAssertEqualObjects(xs.recordedEvents[6].value.element.subscriptions, @[
            Subscription(850, 950)
    ]);
}

- (void)testFlatMapFirst_Complete_ErrorOuter {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable<RxTestableObservable<NSNumber *> *> *xs = [scheduler createHotObservable:@[
            next(5, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(105, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(300, [scheduler createColdObservable:@[
                    next(10, @102),
                    next(90, @103),
                    next(110, @104),
                    next(190, @105),
                    next(440, @106),
                    completed(460)
            ]]),
            next(400, [scheduler createColdObservable:@[
                    next(180, @202),
                    next(190, @203),
            ]]),
            next(550, [scheduler createColdObservable:@[
                    next(10, @301),
                    next(50, @302),
                    next(70, @303),
                    next(260, @304),
                    next(310, @305),
                    completed(410)
            ]]),
            next(750, [scheduler createColdObservable:@[
                    completed(40)
            ]]),
            next(850, [scheduler createColdObservable:@[
                    next(80, @401),
                    next(90, @402),
                    completed(100)
            ]]),
            error(900, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs flatMapFirst:^id <RxObservableConvertibleType>(id element) {
        return element;
    }]];

    NSArray *events = @[
            next(310, @102),
            next(390, @103),
            next(410, @104),
            next(490, @105),
            next(740, @106),
            error(900, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 900)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[2].value.element.subscriptions, @[
            Subscription(300, 760)
    ]);
    XCTAssertEqualObjects(xs.recordedEvents[3].value.element.subscriptions, @[]);
    XCTAssertEqualObjects(xs.recordedEvents[4].value.element.subscriptions, @[]);
    XCTAssertEqualObjects(xs.recordedEvents[5].value.element.subscriptions, @[]);
    XCTAssertEqualObjects(xs.recordedEvents[6].value.element.subscriptions, @[
            Subscription(850, 900)
    ]);
}

- (void)testFlatMapFirst_Error_Inner {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable<RxTestableObservable<NSNumber *> *> *xs = [scheduler createHotObservable:@[
            next(5, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(105, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(300, [scheduler createColdObservable:@[
                    next(10, @102),
                    next(90, @103),
                    next(110, @104),
                    next(190, @105),
                    next(440, @106),
                    error(460, testError()),
            ]]),
            next(400, [scheduler createColdObservable:@[
                    next(180, @202),
                    next(190, @203),
                    completed(205)
            ]]),
            next(550, [scheduler createColdObservable:@[
                    next(10, @301),
                    next(50, @302),
                    next(70, @303),
                    next(260, @304),
                    next(310, @305),
                    completed(410)
            ]]),
            next(750, [scheduler createColdObservable:@[
                    completed(40)
            ]]),
            next(850, [scheduler createColdObservable:@[
                    next(80, @401),
                    next(90, @402),
                    completed(100)
            ]]),
            completed(900)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs flatMapFirst:^id <RxObservableConvertibleType>(id element) {
        return element;
    }]];

    NSArray *events = @[
            next(310, @102),
            next(390, @103),
            next(410, @104),
            next(490, @105),
            next(740, @106),
            error(760, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 760)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[2].value.element.subscriptions, @[
            Subscription(300, 760)
    ]);
    XCTAssertEqualObjects(xs.recordedEvents[3].value.element.subscriptions, @[]);
    XCTAssertEqualObjects(xs.recordedEvents[4].value.element.subscriptions, @[]);
    XCTAssertEqualObjects(xs.recordedEvents[5].value.element.subscriptions, @[]);
    XCTAssertEqualObjects(xs.recordedEvents[6].value.element.subscriptions, @[

    ]);
}

- (void)testFlatMapFirst_Dispose {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable<RxTestableObservable<NSNumber *> *> *xs = [scheduler createHotObservable:@[
            next(5, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(105, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(300, [scheduler createColdObservable:@[
                    next(10, @102),
                    next(90, @103),
                    next(110, @104),
                    next(190, @105),
                    next(440, @106),
                    completed(460)
            ]]),
            next(400, [scheduler createColdObservable:@[
                    next(180, @202),
                    next(190, @203),
                    completed(205)
            ]]),
            next(550, [scheduler createColdObservable:@[
                    next(10, @301),
                    next(50, @302),
                    next(70, @303),
                    next(260, @304),
                    next(310, @305),
                    completed(410)
            ]]),
            next(750, [scheduler createColdObservable:@[
                    completed(40)
            ]]),
            next(850, [scheduler createColdObservable:@[
                    next(80, @401),
                    next(90, @402),
                    completed(100)
            ]]),
            completed(900)
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:700 create:^RxObservable * {
        return [xs flatMapFirst:^id <RxObservableConvertibleType>(id element) {
            return element;
        }];
    }];

    NSArray *events = @[
            next(310, @102),
            next(390, @103),
            next(410, @104),
            next(490, @105),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 700)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[2].value.element.subscriptions, @[
            Subscription(300, 700)
    ]);
    XCTAssertEqualObjects(xs.recordedEvents[3].value.element.subscriptions, @[]);
    XCTAssertEqualObjects(xs.recordedEvents[4].value.element.subscriptions, @[]);
    XCTAssertEqualObjects(xs.recordedEvents[5].value.element.subscriptions, @[]);
    XCTAssertEqualObjects(xs.recordedEvents[6].value.element.subscriptions, @[

    ]);
}

- (void)testFlatMapFirst_SelectorThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable<RxTestableObservable<NSNumber *> *> *xs = [scheduler createHotObservable:@[
            next(5, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(105, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(300, [scheduler createColdObservable:@[
                    next(10, @102),
                    next(90, @103),
                    next(110, @104),
                    next(190, @105),
                    next(440, @106),
                    completed(460)
            ]]),
            next(400, [scheduler createColdObservable:@[
                    next(180, @202),
                    next(190, @203),
                    completed(205)
            ]]),
            next(550, [scheduler createColdObservable:@[
                    next(10, @301),
                    next(50, @302),
                    next(70, @303),
                    next(260, @304),
                    next(310, @305),
                    completed(410)
            ]]),
            next(750, [scheduler createColdObservable:@[
                    completed(40)
            ]]),
            next(850, [scheduler createColdObservable:@[
                    next(80, @401),
                    next(90, @402),
                    completed(100)
            ]]),
            completed(900)
    ]];

    __block NSInteger invoked = 0;
    RxTestableObserver *res = [scheduler startWithObservable:[xs flatMapFirst:^id <RxObservableConvertibleType>(id element) {
        invoked++;
        if (invoked == 2) {
            @throw testError1();
        }
        return element;
    }]];

    NSArray *events = @[
            next(310, @102),
            next(390, @103),
            next(410, @104),
            next(490, @105),
            next(740, @106),
            error(850, testError1())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 850)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[2].value.element.subscriptions, @[
            Subscription(300, 760)
    ]);
    XCTAssertEqualObjects(xs.recordedEvents[3].value.element.subscriptions, @[]);
    XCTAssertEqualObjects(xs.recordedEvents[4].value.element.subscriptions, @[]);
    XCTAssertEqualObjects(xs.recordedEvents[5].value.element.subscriptions, @[]);
    XCTAssertEqualObjects(xs.recordedEvents[6].value.element.subscriptions, @[

    ]);
}

- (void)testFlatMapFirst_UseFunction {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(210, @4),
            next(220, @3),
            next(250, @5),
            next(270, @1),
            completed(290)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs flatMapFirst:^id <RxObservableConvertibleType>(NSNumber *x) {
        return [[[RxObservable interval:10 scheduler:scheduler]
                map:^id(id element) {
                    return x;
                }]
                take:x.unsignedIntegerValue];
    }]];

    NSArray *events = @[
            next(220, @4),
            next(230, @4),
            next(240, @4),
            next(250, @4),
            next(280, @1),
            completed(290)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 290)
    ]);
}

@end

@implementation RxObservableStandardSequenceOperatorsTest (FlatMap)

- (void)testFlatMap_Complete {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable<RxTestableObservable<NSNumber *> *> *xs = [scheduler createHotObservable:@[
            next(5, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(105, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(300, [scheduler createColdObservable:@[
                    next(10, @102),
                    next(90, @103),
                    next(110, @104),
                    next(190, @105),
                    next(440, @106),
                    completed(460)
            ]]),
            next(400, [scheduler createColdObservable:@[
                    next(180, @202),
                    next(190, @203),
                    completed(205)
            ]]),
            next(550, [scheduler createColdObservable:@[
                    next(10, @301),
                    next(50, @302),
                    next(70, @303),
                    next(260, @304),
                    next(310, @305),
                    completed(410)
            ]]),
            next(750, [scheduler createColdObservable:@[
                    completed(40)
            ]]),
            next(850, [scheduler createColdObservable:@[
                    next(80, @401),
                    next(90, @402),
                    completed(100)
            ]]),
            completed(900)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs flatMap:RxReturnSelf()]];

    NSArray *events = @[
            next(310, @102),
            next(390, @103),
            next(410, @104),
            next(490, @105),
            next(560, @301),
            next(580, @202),
            next(590, @203),
            next(600, @302),
            next(620, @303),
            next(740, @106),
            next(810, @304),
            next(860, @305),
            next(930, @401),
            next(940, @402),
            completed(960)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 900)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[2].value.element.subscriptions, @[
            Subscription(300, 760)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[3].value.element.subscriptions, @[
            Subscription(400, 605)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[4].value.element.subscriptions, @[
            Subscription(550, 960)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[5].value.element.subscriptions, @[
            Subscription(750, 790)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[6].value.element.subscriptions, @[
            Subscription(850, 950)
    ]);
}

- (void)testFlatMap_Complete_InnerNotComplete {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable<RxTestableObservable<NSNumber *> *> *xs = [scheduler createHotObservable:@[
            next(5, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(105, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(300, [scheduler createColdObservable:@[
                    next(10, @102),
                    next(90, @103),
                    next(110, @104),
                    next(190, @105),
                    next(440, @106),
                    completed(460)
            ]]),
            next(400, [scheduler createColdObservable:@[
                    next(180, @202),
                    next(190, @203),
                    completed(205)
            ]]),
            next(550, [scheduler createColdObservable:@[
                    next(10, @301),
                    next(50, @302),
                    next(70, @303),
                    next(260, @304),
                    next(310, @305),
                    completed(410)
            ]]),
            next(750, [scheduler createColdObservable:@[
                    completed(40)
            ]]),
            next(850, [scheduler createColdObservable:@[
                    next(80, @401),
                    next(90, @402),
                    completed(100)
            ]])
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs flatMap:RxReturnSelf()]];

    NSArray *events = @[
            next(310, @102),
            next(390, @103),
            next(410, @104),
            next(490, @105),
            next(560, @301),
            next(580, @202),
            next(590, @203),
            next(600, @302),
            next(620, @303),
            next(740, @106),
            next(810, @304),
            next(860, @305),
            next(930, @401),
            next(940, @402),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 1000)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[2].value.element.subscriptions, @[
            Subscription(300, 760)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[3].value.element.subscriptions, @[
            Subscription(400, 605)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[4].value.element.subscriptions, @[
            Subscription(550, 960)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[5].value.element.subscriptions, @[
            Subscription(750, 790)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[6].value.element.subscriptions, @[
            Subscription(850, 950)
    ]);
}

- (void)testFlatMap_Complete_OuterNotComplete {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable<RxTestableObservable<NSNumber *> *> *xs = [scheduler createHotObservable:@[
            next(5, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(105, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(300, [scheduler createColdObservable:@[
                    next(10, @102),
                    next(90, @103),
                    next(110, @104),
                    next(190, @105),
                    next(440, @106),
                    completed(460)
            ]]),
            next(400, [scheduler createColdObservable:@[
                    next(180, @202),
                    next(190, @203),
            ]]),
            next(550, [scheduler createColdObservable:@[
                    next(10, @301),
                    next(50, @302),
                    next(70, @303),
                    next(260, @304),
                    next(310, @305),
                    completed(410)
            ]]),
            next(750, [scheduler createColdObservable:@[
                    completed(40)
            ]]),
            next(850, [scheduler createColdObservable:@[
                    next(80, @401),
                    next(90, @402),
                    completed(100)
            ]]),
            completed(900),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs flatMap:RxReturnSelf()]];

    NSArray *events = @[
            next(310, @102),
            next(390, @103),
            next(410, @104),
            next(490, @105),
            next(560, @301),
            next(580, @202),
            next(590, @203),
            next(600, @302),
            next(620, @303),
            next(740, @106),
            next(810, @304),
            next(860, @305),
            next(930, @401),
            next(940, @402),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 900)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[2].value.element.subscriptions, @[
            Subscription(300, 760)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[3].value.element.subscriptions, @[
            Subscription(400, 1000)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[4].value.element.subscriptions, @[
            Subscription(550, 960)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[5].value.element.subscriptions, @[
            Subscription(750, 790)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[6].value.element.subscriptions, @[
            Subscription(850, 950)
    ]);
}

- (void)testFlatMap_Complete_ErrorOuter {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable<RxTestableObservable<NSNumber *> *> *xs = [scheduler createHotObservable:@[
            next(5, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(105, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(300, [scheduler createColdObservable:@[
                    next(10, @102),
                    next(90, @103),
                    next(110, @104),
                    next(190, @105),
                    next(440, @106),
                    completed(460)
            ]]),
            next(400, [scheduler createColdObservable:@[
                    next(180, @202),
                    next(190, @203),
            ]]),
            next(550, [scheduler createColdObservable:@[
                    next(10, @301),
                    next(50, @302),
                    next(70, @303),
                    next(260, @304),
                    next(310, @305),
                    completed(410)
            ]]),
            next(750, [scheduler createColdObservable:@[
                    completed(40)
            ]]),
            next(850, [scheduler createColdObservable:@[
                    next(80, @401),
                    next(90, @402),
                    completed(100)
            ]]),
            error(900, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs flatMap:RxReturnSelf()]];

    NSArray *events = @[
            next(310, @102),
            next(390, @103),
            next(410, @104),
            next(490, @105),
            next(560, @301),
            next(580, @202),
            next(590, @203),
            next(600, @302),
            next(620, @303),
            next(740, @106),
            next(810, @304),
            next(860, @305),
            error(900, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 900)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[2].value.element.subscriptions, @[
            Subscription(300, 760)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[3].value.element.subscriptions, @[
            Subscription(400, 900)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[4].value.element.subscriptions, @[
            Subscription(550, 900)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[5].value.element.subscriptions, @[
            Subscription(750, 790)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[6].value.element.subscriptions, @[
            Subscription(850, 900)
    ]);
}

- (void)testFlatMap_Error_Inner {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable<RxTestableObservable<NSNumber *> *> *xs = [scheduler createHotObservable:@[
            next(5, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(105, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(300, [scheduler createColdObservable:@[
                    next(10, @102),
                    next(90, @103),
                    next(110, @104),
                    next(190, @105),
                    next(440, @106),
                    error(460, testError())
            ]]),
            next(400, [scheduler createColdObservable:@[
                    next(180, @202),
                    next(190, @203),
                    completed(205),
            ]]),
            next(550, [scheduler createColdObservable:@[
                    next(10, @301),
                    next(50, @302),
                    next(70, @303),
                    next(260, @304),
                    next(310, @305),
                    completed(410)
            ]]),
            next(750, [scheduler createColdObservable:@[
                    completed(40)
            ]]),
            next(850, [scheduler createColdObservable:@[
                    next(80, @401),
                    next(90, @402),
                    completed(100)
            ]]),
            completed(900)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs flatMap:RxReturnSelf()]];

    NSArray *events = @[
            next(310, @102),
            next(390, @103),
            next(410, @104),
            next(490, @105),
            next(560, @301),
            next(580, @202),
            next(590, @203),
            next(600, @302),
            next(620, @303),
            next(740, @106),
            error(760, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 760)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[2].value.element.subscriptions, @[
            Subscription(300, 760)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[3].value.element.subscriptions, @[
            Subscription(400, 605)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[4].value.element.subscriptions, @[
            Subscription(550, 760)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[5].value.element.subscriptions, @[
            Subscription(750, 760)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[6].value.element.subscriptions, @[

    ]);
}

- (void)testFlatMap_Dispose {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable<RxTestableObservable<NSNumber *> *> *xs = [scheduler createHotObservable:@[
            next(5, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(105, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(300, [scheduler createColdObservable:@[
                    next(10, @102),
                    next(90, @103),
                    next(110, @104),
                    next(190, @105),
                    next(440, @106),
                    completed(460)
            ]]),
            next(400, [scheduler createColdObservable:@[
                    next(180, @202),
                    next(190, @203),
                    completed(205),
            ]]),
            next(550, [scheduler createColdObservable:@[
                    next(10, @301),
                    next(50, @302),
                    next(70, @303),
                    next(260, @304),
                    next(310, @305),
                    completed(410)
            ]]),
            next(750, [scheduler createColdObservable:@[
                    completed(40)
            ]]),
            next(850, [scheduler createColdObservable:@[
                    next(80, @401),
                    next(90, @402),
                    completed(100)
            ]]),
            completed(900)
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:700 create:^RxObservable * {
        return [xs flatMap:RxReturnSelf()];
    }];

    NSArray *events = @[
            next(310, @102),
            next(390, @103),
            next(410, @104),
            next(490, @105),
            next(560, @301),
            next(580, @202),
            next(590, @203),
            next(600, @302),
            next(620, @303),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 700)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[2].value.element.subscriptions, @[
            Subscription(300, 700)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[3].value.element.subscriptions, @[
            Subscription(400, 605)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[4].value.element.subscriptions, @[
            Subscription(550, 700)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[5].value.element.subscriptions, @[
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[6].value.element.subscriptions, @[

    ]);
}

- (void)testFlatMap_SelectorThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable<RxTestableObservable<NSNumber *> *> *xs = [scheduler createHotObservable:@[
            next(5, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(105, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(300, [scheduler createColdObservable:@[
                    next(10, @102),
                    next(90, @103),
                    next(110, @104),
                    next(190, @105),
                    next(440, @106),
                    completed(460)
            ]]),
            next(400, [scheduler createColdObservable:@[
                    next(180, @202),
                    next(190, @203),
                    completed(205),
            ]]),
            next(550, [scheduler createColdObservable:@[
                    next(10, @301),
                    next(50, @302),
                    next(70, @303),
                    next(260, @304),
                    next(310, @305),
                    completed(410)
            ]]),
            next(750, [scheduler createColdObservable:@[
                    completed(40)
            ]]),
            next(850, [scheduler createColdObservable:@[
                    next(80, @401),
                    next(90, @402),
                    completed(100)
            ]]),
            completed(900)
    ]];

    __block NSInteger invoked = 0;
    RxTestableObserver *res = [scheduler startWithObservable:[xs flatMap:^id <RxObservableConvertibleType>(id element) {
        invoked++;
        if (invoked == 3) {
            @throw testError();
        }
        return element;
    }]];

    NSArray *events = @[
            next(310, @102),
            next(390, @103),
            next(410, @104),
            next(490, @105),
            error(550, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 550)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[2].value.element.subscriptions, @[
            Subscription(300, 550)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[3].value.element.subscriptions, @[
            Subscription(400, 550)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[4].value.element.subscriptions, @[
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[5].value.element.subscriptions, @[
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[6].value.element.subscriptions, @[

    ]);
}

- (void)testFlatMap_UseFunction {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(210, @4),
            next(220, @3),
            next(250, @5),
            next(270, @1),
            completed(290)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs flatMap:^id <RxObservableConvertibleType>(NSNumber *element) {
        return [[[RxObservable interval:10 scheduler:scheduler]
                map:^id(id _) {
                    return element;
                }]
                take:element.unsignedIntegerValue];
    }]];

    NSArray *events = @[
            next(220, @4),
            next(230, @3),
            next(230, @4),
            next(240, @3),
            next(240, @4),
            next(250, @3),
            next(250, @4),
            next(260, @5),
            next(270, @5),
            next(280, @1),
            next(280, @5),
            next(290, @5),
            next(300, @5),
            completed(300)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 290)
    ]);
}

- (void)testFlatMapIndex_Index {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(210, @4),
            next(220, @3),
            next(250, @5),
            next(270, @1),
            completed(290)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs flatMapWithIndex:^id <RxObservableConvertibleType>(NSNumber *element, NSUInteger index) {
        return [RxObservable just:[[RxElementIndexPair alloc] initWithElement:element index:index]];
    }]];

    NSArray *events = @[
            next(210, [[RxElementIndexPair alloc] initWithElement:@4 index:0]),
            next(220, [[RxElementIndexPair alloc] initWithElement:@3 index:1]),
            next(250, [[RxElementIndexPair alloc] initWithElement:@5 index:2]),
            next(270, [[RxElementIndexPair alloc] initWithElement:@1 index:3]),
            completed(290)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 290)
    ]);
}

- (void)testFlatMapWithIndex_Complete {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable<RxTestableObservable<NSNumber *> *> *xs = [scheduler createHotObservable:@[
            next(5, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(105, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(300, [scheduler createColdObservable:@[
                    next(10, @102),
                    next(90, @103),
                    next(110, @104),
                    next(190, @105),
                    next(440, @106),
                    completed(460)
            ]]),
            next(400, [scheduler createColdObservable:@[
                    next(180, @202),
                    next(190, @203),
                    completed(205),
            ]]),
            next(550, [scheduler createColdObservable:@[
                    next(10, @301),
                    next(50, @302),
                    next(70, @303),
                    next(260, @304),
                    next(310, @305),
                    completed(410)
            ]]),
            next(750, [scheduler createColdObservable:@[
                    completed(40)
            ]]),
            next(850, [scheduler createColdObservable:@[
                    next(80, @401),
                    next(90, @402),
                    completed(100)
            ]]),
            completed(900)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs flatMapWithIndex:^id <RxObservableConvertibleType>(id element, NSUInteger index) {
        return element;
    }]];

    NSArray *events = @[
            next(310, @102),
            next(390, @103),
            next(410, @104),
            next(490, @105),
            next(560, @301),
            next(580, @202),
            next(590, @203),
            next(600, @302),
            next(620, @303),
            next(740, @106),
            next(810, @304),
            next(860, @305),
            next(930, @401),
            next(940, @402),
            completed(960)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 900)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[2].value.element.subscriptions, @[
            Subscription(300, 760)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[3].value.element.subscriptions, @[
            Subscription(400, 605)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[4].value.element.subscriptions, @[
            Subscription(550, 960)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[5].value.element.subscriptions, @[
            Subscription(750, 790)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[6].value.element.subscriptions, @[
            Subscription(850, 950)
    ]);
}

- (void)testFlatMapWithIndex_Complete_InnerNotComplete {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable<RxTestableObservable<NSNumber *> *> *xs = [scheduler createHotObservable:@[
            next(5, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(105, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(300, [scheduler createColdObservable:@[
                    next(10, @102),
                    next(90, @103),
                    next(110, @104),
                    next(190, @105),
                    next(440, @106),
                    completed(460)
            ]]),
            next(400, [scheduler createColdObservable:@[
                    next(180, @202),
                    next(190, @203),
                    completed(205),
            ]]),
            next(550, [scheduler createColdObservable:@[
                    next(10, @301),
                    next(50, @302),
                    next(70, @303),
                    next(260, @304),
                    next(310, @305),
                    completed(410)
            ]]),
            next(750, [scheduler createColdObservable:@[
                    completed(40)
            ]]),
            next(850, [scheduler createColdObservable:@[
                    next(80, @401),
                    next(90, @402),
                    completed(100)
            ]]),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs flatMapWithIndex:^id <RxObservableConvertibleType>(id element, NSUInteger index) {
        return element;
    }]];

    NSArray *events = @[
            next(310, @102),
            next(390, @103),
            next(410, @104),
            next(490, @105),
            next(560, @301),
            next(580, @202),
            next(590, @203),
            next(600, @302),
            next(620, @303),
            next(740, @106),
            next(810, @304),
            next(860, @305),
            next(930, @401),
            next(940, @402),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 1000)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[2].value.element.subscriptions, @[
            Subscription(300, 760)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[3].value.element.subscriptions, @[
            Subscription(400, 605)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[4].value.element.subscriptions, @[
            Subscription(550, 960)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[5].value.element.subscriptions, @[
            Subscription(750, 790)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[6].value.element.subscriptions, @[
            Subscription(850, 950)
    ]);
}

- (void)testFlatMapWithIndex_Complete_OuterNotComplete {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable<RxTestableObservable<NSNumber *> *> *xs = [scheduler createHotObservable:@[
            next(5, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(105, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(300, [scheduler createColdObservable:@[
                    next(10, @102),
                    next(90, @103),
                    next(110, @104),
                    next(190, @105),
                    next(440, @106),
                    completed(460)
            ]]),
            next(400, [scheduler createColdObservable:@[
                    next(180, @202),
                    next(190, @203),
            ]]),
            next(550, [scheduler createColdObservable:@[
                    next(10, @301),
                    next(50, @302),
                    next(70, @303),
                    next(260, @304),
                    next(310, @305),
                    completed(410)
            ]]),
            next(750, [scheduler createColdObservable:@[
                    completed(40)
            ]]),
            next(850, [scheduler createColdObservable:@[
                    next(80, @401),
                    next(90, @402),
                    completed(100)
            ]]),
            completed(900)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs flatMapWithIndex:^id <RxObservableConvertibleType>(id element, NSUInteger index) {
        return element;
    }]];

    NSArray *events = @[
            next(310, @102),
            next(390, @103),
            next(410, @104),
            next(490, @105),
            next(560, @301),
            next(580, @202),
            next(590, @203),
            next(600, @302),
            next(620, @303),
            next(740, @106),
            next(810, @304),
            next(860, @305),
            next(930, @401),
            next(940, @402),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 900)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[2].value.element.subscriptions, @[
            Subscription(300, 760)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[3].value.element.subscriptions, @[
            Subscription(400, 1000)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[4].value.element.subscriptions, @[
            Subscription(550, 960)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[5].value.element.subscriptions, @[
            Subscription(750, 790)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[6].value.element.subscriptions, @[
            Subscription(850, 950)
    ]);
}

- (void)testFlatMapWithIndex_Complete_ErrorOuter {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable<RxTestableObservable<NSNumber *> *> *xs = [scheduler createHotObservable:@[
            next(5, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(105, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(300, [scheduler createColdObservable:@[
                    next(10, @102),
                    next(90, @103),
                    next(110, @104),
                    next(190, @105),
                    next(440, @106),
                    completed(460)
            ]]),
            next(400, [scheduler createColdObservable:@[
                    next(180, @202),
                    next(190, @203),
            ]]),
            next(550, [scheduler createColdObservable:@[
                    next(10, @301),
                    next(50, @302),
                    next(70, @303),
                    next(260, @304),
                    next(310, @305),
                    completed(410)
            ]]),
            next(750, [scheduler createColdObservable:@[
                    completed(40)
            ]]),
            next(850, [scheduler createColdObservable:@[
                    next(80, @401),
                    next(90, @402),
                    completed(100)
            ]]),
            error(900, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs flatMapWithIndex:^id <RxObservableConvertibleType>(id element, NSUInteger index) {
        return element;
    }]];

    NSArray *events = @[
            next(310, @102),
            next(390, @103),
            next(410, @104),
            next(490, @105),
            next(560, @301),
            next(580, @202),
            next(590, @203),
            next(600, @302),
            next(620, @303),
            next(740, @106),
            next(810, @304),
            next(860, @305),
            error(900, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 900)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[2].value.element.subscriptions, @[
            Subscription(300, 760)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[3].value.element.subscriptions, @[
            Subscription(400, 900)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[4].value.element.subscriptions, @[
            Subscription(550, 900)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[5].value.element.subscriptions, @[
            Subscription(750, 790)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[6].value.element.subscriptions, @[
            Subscription(850, 900)
    ]);
}

- (void)testFlatMapWithIndex_Error_Inner {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable<RxTestableObservable<NSNumber *> *> *xs = [scheduler createHotObservable:@[
            next(5, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(105, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(300, [scheduler createColdObservable:@[
                    next(10, @102),
                    next(90, @103),
                    next(110, @104),
                    next(190, @105),
                    next(440, @106),
                    error(460, testError())
            ]]),
            next(400, [scheduler createColdObservable:@[
                    next(180, @202),
                    next(190, @203),
                    completed(205),
            ]]),
            next(550, [scheduler createColdObservable:@[
                    next(10, @301),
                    next(50, @302),
                    next(70, @303),
                    next(260, @304),
                    next(310, @305),
                    completed(410)
            ]]),
            next(750, [scheduler createColdObservable:@[
                    completed(40)
            ]]),
            next(850, [scheduler createColdObservable:@[
                    next(80, @401),
                    next(90, @402),
                    completed(100)
            ]]),
            completed(900)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs flatMapWithIndex:^id <RxObservableConvertibleType>(id element, NSUInteger index) {
        return element;
    }]];

    NSArray *events = @[
            next(310, @102),
            next(390, @103),
            next(410, @104),
            next(490, @105),
            next(560, @301),
            next(580, @202),
            next(590, @203),
            next(600, @302),
            next(620, @303),
            next(740, @106),
            error(760, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 760)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[2].value.element.subscriptions, @[
            Subscription(300, 760)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[3].value.element.subscriptions, @[
            Subscription(400, 605)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[4].value.element.subscriptions, @[
            Subscription(550, 760)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[5].value.element.subscriptions, @[
            Subscription(750, 760)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[6].value.element.subscriptions, @[
    ]);
}

- (void)testFlatMapWithIndex_Dispose {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable<RxTestableObservable<NSNumber *> *> *xs = [scheduler createHotObservable:@[
            next(5, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(105, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(300, [scheduler createColdObservable:@[
                    next(10, @102),
                    next(90, @103),
                    next(110, @104),
                    next(190, @105),
                    next(440, @106),
                    completed(460)
            ]]),
            next(400, [scheduler createColdObservable:@[
                    next(180, @202),
                    next(190, @203),
                    completed(205),
            ]]),
            next(550, [scheduler createColdObservable:@[
                    next(10, @301),
                    next(50, @302),
                    next(70, @303),
                    next(260, @304),
                    next(310, @305),
                    completed(410)
            ]]),
            next(750, [scheduler createColdObservable:@[
                    completed(40)
            ]]),
            next(850, [scheduler createColdObservable:@[
                    next(80, @401),
                    next(90, @402),
                    completed(100)
            ]]),
            completed(900)
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:700 create:^RxObservable * {
        return [xs flatMapWithIndex:^id <RxObservableConvertibleType>(id element, NSUInteger index) {
            return element;
        }];
    }];

    NSArray *events = @[
            next(310, @102),
            next(390, @103),
            next(410, @104),
            next(490, @105),
            next(560, @301),
            next(580, @202),
            next(590, @203),
            next(600, @302),
            next(620, @303),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 700)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[2].value.element.subscriptions, @[
            Subscription(300, 700)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[3].value.element.subscriptions, @[
            Subscription(400, 605)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[4].value.element.subscriptions, @[
            Subscription(550, 700)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[5].value.element.subscriptions, @[
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[6].value.element.subscriptions, @[
    ]);
}

- (void)testFlatMapWithIndex_SelectorThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable<RxTestableObservable<NSNumber *> *> *xs = [scheduler createHotObservable:@[
            next(5, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(105, [scheduler createColdObservable:@[
                    error(1, testError())
            ]]),
            next(300, [scheduler createColdObservable:@[
                    next(10, @102),
                    next(90, @103),
                    next(110, @104),
                    next(190, @105),
                    next(440, @106),
                    completed(460)
            ]]),
            next(400, [scheduler createColdObservable:@[
                    next(180, @202),
                    next(190, @203),
                    completed(205),
            ]]),
            next(550, [scheduler createColdObservable:@[
                    next(10, @301),
                    next(50, @302),
                    next(70, @303),
                    next(260, @304),
                    next(310, @305),
                    completed(410)
            ]]),
            next(750, [scheduler createColdObservable:@[
                    completed(40)
            ]]),
            next(850, [scheduler createColdObservable:@[
                    next(80, @401),
                    next(90, @402),
                    completed(100)
            ]]),
            completed(900)
    ]];

    __block int invoked = 0;
    RxTestableObserver *res = [scheduler startWithObservable:[xs flatMapWithIndex:^id <RxObservableConvertibleType>(NSNumber *element, NSUInteger index) {
        invoked++;
        if (invoked == 3) {
            @throw testError();
        }
        return element;
    }]];

    NSArray *events = @[
            next(310, @102),
            next(390, @103),
            next(410, @104),
            next(490, @105),
            error(550, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 550)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[2].value.element.subscriptions, @[
            Subscription(300, 550)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[3].value.element.subscriptions, @[
            Subscription(400, 550)
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[4].value.element.subscriptions, @[
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[5].value.element.subscriptions, @[
    ]);

    XCTAssertEqualObjects(xs.recordedEvents[6].value.element.subscriptions, @[
    ]);
}

- (void)testFlatMapWithIndex_UseFunction {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(210, @4),
            next(220, @3),
            next(250, @5),
            next(270, @1),
            completed(290)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs flatMapWithIndex:^id <RxObservableConvertibleType>(NSNumber *element, NSUInteger index) {
        return [[[RxObservable interval:10 scheduler:scheduler]
                map:^id(id _) {
                    return element;
                }]
                take:element.unsignedIntegerValue];
    }]];

    NSArray *events = @[
            next(220, @4),
            next(230, @3),
            next(230, @4),
            next(240, @3),
            next(240, @4),
            next(250, @3),
            next(250, @4),
            next(260, @5),
            next(270, @5),
            next(280, @1),
            next(280, @5),
            next(290, @5),
            next(300, @5),
            completed(300)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 290)
    ]);
}

@end

#pragma clang diagnostic pop