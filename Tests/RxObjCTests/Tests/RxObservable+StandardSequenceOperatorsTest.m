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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable filter:^BOOL(NSNumber *n) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable filter:^BOOL(NSNumber *n) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable filter:^BOOL(NSNumber *n) {
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
        return [xs.asObservable filter:^BOOL(NSNumber *n) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable takeWhile:^BOOL(NSNumber *n) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable takeWhile:^BOOL(NSNumber *n) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable takeWhile:^BOOL(NSNumber *n) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable takeWhile:^BOOL(NSNumber *n) {
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
        return [xs.asObservable takeWhile:^BOOL(NSNumber *n) {
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
        return [xs.asObservable takeWhile:^BOOL(NSNumber *n) {
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
        return [xs.asObservable takeWhile:^BOOL(NSNumber *n) {
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
        return [xs.asObservable takeWhile:^BOOL(NSNumber *n) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable takeWhileWithIndex:^BOOL(NSNumber *num, NSUInteger index) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable takeWhileWithIndex:^BOOL(NSNumber *num, NSUInteger index) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable takeWhileWithIndex:^BOOL(NSNumber *num, NSUInteger index) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable takeWhileWithIndex:^BOOL(NSNumber *num, NSUInteger index) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable map:^NSNumber *(NSNumber *o) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable map:^NSNumber *(NSNumber *o) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable map:^NSNumber *(NSNumber *o) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable map:^NSNumber *(NSNumber *o) {
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
        return [xs.asObservable map:^NSNumber *(NSNumber *o) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable map:^NSNumber *(NSNumber *o) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable mapWithIndex:^NSNumber *(NSNumber *element, NSInteger index) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable mapWithIndex:^NSNumber *(NSNumber *element, NSInteger index) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable mapWithIndex:^NSNumber *(NSNumber *element, NSInteger index) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable mapWithIndex:^NSNumber *(NSNumber *element, NSInteger index) {
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
        return [xs.asObservable mapWithIndex:^NSNumber *(NSNumber *element, NSInteger index) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable mapWithIndex:^NSNumber *(NSNumber *element, NSInteger index) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[[xs.asObservable map:^NSNumber *(NSNumber *element) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[[xs.asObservable map:^NSNumber *(NSNumber *element) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[[xs.asObservable map:^NSNumber *(NSNumber *element) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[[xs.asObservable map:^NSNumber *(NSNumber *element) {
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
        return [[xs.asObservable map:^NSNumber *(NSNumber *element) {
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
        return [[xs.asObservable map:^NSNumber *(NSNumber *element) {
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
        return [[xs.asObservable map:^NSNumber *(NSNumber *element) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[[xs.asObservable map:^NSNumber *(NSNumber *element) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[[[xs.asObservable map:^NSNumber *(NSNumber *element) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable flatMapFirst:^id <RxObservableConvertibleType>(id element) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable flatMapFirst:^id <RxObservableConvertibleType>(id element) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable flatMapFirst:^id <RxObservableConvertibleType>(id element) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable flatMapFirst:^id <RxObservableConvertibleType>(id element) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable flatMapFirst:^id <RxObservableConvertibleType>(id element) {
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
        return [xs.asObservable flatMapFirst:^id <RxObservableConvertibleType>(id element) {
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
    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable flatMapFirst:^id <RxObservableConvertibleType>(id element) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable flatMapFirst:^id <RxObservableConvertibleType>(NSNumber *x) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable flatMap:RxReturnSelf()]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable flatMap:RxReturnSelf()]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable flatMap:RxReturnSelf()]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable flatMap:RxReturnSelf()]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable flatMap:RxReturnSelf()]];

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
        return [xs.asObservable flatMap:RxReturnSelf()];
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
    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable flatMap:^id <RxObservableConvertibleType>(id element) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable flatMap:^id <RxObservableConvertibleType>(NSNumber *element) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable flatMapWithIndex:^id <RxObservableConvertibleType>(NSNumber *element, NSUInteger index) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable flatMapWithIndex:^id <RxObservableConvertibleType>(id element, NSUInteger index) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable flatMapWithIndex:^id <RxObservableConvertibleType>(id element, NSUInteger index) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable flatMapWithIndex:^id <RxObservableConvertibleType>(id element, NSUInteger index) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable flatMapWithIndex:^id <RxObservableConvertibleType>(id element, NSUInteger index) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable flatMapWithIndex:^id <RxObservableConvertibleType>(id element, NSUInteger index) {
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
        return [xs.asObservable flatMapWithIndex:^id <RxObservableConvertibleType>(id element, NSUInteger index) {
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
    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable flatMapWithIndex:^id <RxObservableConvertibleType>(NSNumber *element, NSUInteger index) {
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable flatMapWithIndex:^id <RxObservableConvertibleType>(NSNumber *element, NSUInteger index) {
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

@implementation RxObservableStandardSequenceOperatorsTest (Take)

- (void)testTake_Complete_After {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            completed(690)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable take:20]];

    NSArray *events = @[
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            completed(690)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 690)
    ]);
}

- (void)testTake_Complete_Same {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            completed(690)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable take:17]];

    NSArray *events = @[
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            completed(630)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 630)
    ]);
}

- (void)testTake_Complete_Before {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            completed(690)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable take:10]];

    NSArray *events = @[
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            completed(415)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 415)
    ]);
}

- (void)testTake_Error_After {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            error(690, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable take:20]];

    NSArray *events = @[
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            error(690, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 690)
    ]);
}

- (void)testTake_Error_Same {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            error(690, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable take:17]];

    NSArray *events = @[
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            completed(630),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 630)
    ]);
}

- (void)testTake_Error_Before {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            error(690, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable take:3]];

    NSArray *events = @[
            next(210, @9),
            next(230, @13),
            next(270, @7),
            completed(270),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 270)
    ]);
}

- (void)testTake_Dispose_Before {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            error(690, testError())
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:250 create:^RxObservable * {
        return [xs.asObservable take:3];
    }];

    NSArray *events = @[
            next(210, @9),
            next(230, @13),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 250)
    ]);
}

- (void)testTake_Dispose_After {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            error(690, testError())
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:400 create:^RxObservable * {
        return [xs.asObservable take:3];
    }];

    NSArray *events = @[
            next(210, @9),
            next(230, @13),
            next(270, @7),
            completed(270)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 270)
    ]);
}

- (void)testTake_0_DefaultScheduler {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable take:0]];

    NSArray *events = @[
            completed(200)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
    ]);
}

- (void)testTake_Take1 {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            completed(400)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable take:3]];

    NSArray *events = @[
            next(210, @9),
            next(230, @13),
            next(270, @7),
            completed(270)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 270)
    ]);
}

- (void)testTake_DecrementCountsFirst {
    RxBehaviorSubject *k = [RxBehaviorSubject create:@NO];

    [[k take:1] subscribeNext:^(NSNumber *n) {
        [k onNext:@(!n.boolValue)];
    }];
}

@end

@implementation RxObservableStandardSequenceOperatorsTest (TakeLast)

- (void)testTakeLast_Complete_Less {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            completed(300)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable takeLast:7]];

    NSArray *events = @[
            next(300, @9),
            next(300, @13),
            next(300, @7),
            next(300, @1),
            next(300, @(-1)),
            completed(300)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 300)
    ]);
}

- (void)testTakeLast_Complete_Same {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            completed(310)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable takeLast:5]];

    NSArray *events = @[
            next(310, @9),
            next(310, @13),
            next(310, @7),
            next(310, @1),
            next(310, @(-1)),
            completed(310)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 310)
    ]);
}

- (void)testTakeLast_Complete_More {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            completed(350)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable takeLast:5]];

    NSArray *events = @[
            next(350, @7),
            next(350, @1),
            next(350, @(-1)),
            next(350, @3),
            next(350, @8),
            completed(350)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 350)
    ]);
}

- (void)testTakeLast_Error_Less {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(290, @64),
            error(300, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable takeLast:7]];

    NSArray *events = @[
            error(300, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 300)
    ]);
}

- (void)testTakeLast_Error_Same {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            error(310, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable takeLast:5]];

    NSArray *events = @[
            error(310, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 310)
    ]);
}

- (void)testTakeLast_Error_More {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @64),
            error(360, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable takeLast:5]];

    NSArray *events = @[
            error(360, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 360)
    ]);
}

- (void)testTakeLast_0_DefaultScheduler {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable takeLast:0]];

    NSArray *events = @[
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 1000)
    ]);
}

- (void)testTakeLast_TakeLast1 {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            completed(400)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable takeLast:3]];

    NSArray *events = @[
            next(400, @3),
            next(400, @8),
            next(400, @11),
            completed(400)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 400)
    ]);
}

- (void)testTakeLast_DecrementCountsFirst {
    RxBehaviorSubject *k = [RxBehaviorSubject create:@NO];

    NSMutableArray<NSNumber *> *elements = [NSMutableArray array];
    [[k takeLast:1] subscribeNext:^(NSNumber *n) {
        [elements addObject:n];
        [k onNext:@(!n.boolValue)];
    }];

    [k onCompleted];

    XCTAssertEqualObjects(elements, @[@NO]);
}

@end

@implementation RxObservableStandardSequenceOperatorsTest (Skip)

- (void)testSkip_Complete_After {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            completed(690)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable skip:20]];

    NSArray *events = @[
            completed(690),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 690)
    ]);
}

- (void)testSkip_Complete_Some {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            completed(690)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable skip:17]];

    NSArray *events = @[
            completed(690),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 690)
    ]);
}

- (void)testSkip_Complete_Before {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            completed(690)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable skip:10]];

    NSArray *events = @[
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            completed(690)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 690)
    ]);
}

- (void)testSkip_Complete_Zero {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            completed(690)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable skip:0]];

    NSArray *events = @[
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            completed(690)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 690)
    ]);
}

- (void)testSkip_Error_After {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            error(690, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable skip:20]];

    NSArray *events = @[
            error(690, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 690)
    ]);
}

- (void)testSkip_Error_Same {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            error(690, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable skip:17]];

    NSArray *events = @[
            error(690, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 690)
    ]);
}

- (void)testSkip_Error_Before {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            error(690, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable skip:3]];

    NSArray *events = @[
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            error(690, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 690)
    ]);
}

- (void)testSkip_Dispose_Before {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:250 create:^RxObservable * {
        return [xs.asObservable skip:3];
    }];

    NSArray *events = @[

    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 250)
    ]);
}

- (void)testSkip_Dispose_After {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:400 create:^RxObservable * {
        return [xs.asObservable skip:3];
    }];

    NSArray *events = @[
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 400)
    ]);
}

@end

@implementation RxObservableStandardSequenceOperatorsTest (SkipWhile)

- (void)testSkipWhile_Complete_Before {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90,  @(-1)),
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable skipWhile:^BOOL(NSNumber *x) {
        invoked++;
        return isPrime(x);
    }]];

    NSArray *events = @[
            completed(330),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 330)
    ]);

    XCTAssertEqual(invoked, 4);
}

- (void)testSkipWhile_Complete_After {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90,  @(-1)),
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable skipWhile:^BOOL(NSNumber *x) {
        invoked++;
        return isPrime(x);
    }]];

    NSArray *events = @[
            next(390, @4),
            next(410, @17),
            next(450, @8),
            next(500, @23),
            completed(600)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 600)
    ]);

    XCTAssertEqual(invoked, 6);
}

- (void)testSkipWhile_Error_Before {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90,  @(-1)),
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
    ]];

    __block NSInteger invoked = 0;

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable skipWhile:^BOOL(NSNumber *x) {
        invoked++;
        return isPrime(x);
    }]];

    NSArray *events = @[
            error(270, testError()),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 270)
    ]);

    XCTAssertEqual(invoked, 2);
}

- (void)testSkipWhile_Error_After {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90,  @(-1)),
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable skipWhile:^BOOL(NSNumber *x) {
        invoked++;
        return isPrime(x);
    }]];

    NSArray *events = @[
            next(390, @4),
            next(410, @17),
            next(450, @8),
            next(500, @23),
            error(600, testError()),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 600)
    ]);

    XCTAssertEqual(invoked, 6);
}

- (void)testSkipWhile_Dispose_Before {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90,  @(-1)),
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

    RxTestableObserver *res = [scheduler startWhenDisposed:300 create:^RxObservable * {
        return [xs.asObservable skipWhile:^BOOL(NSNumber *x) {
            invoked++;
            return isPrime(x);
        }];
    }];

    NSArray *events = @[
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 300)
    ]);

    XCTAssertEqual(invoked, 3);
}

- (void)testSkipWhile_Dispose_After {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90,  @(-1)),
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

    RxTestableObserver *res = [scheduler startWhenDisposed:470 create:^RxObservable * {
        return [xs.asObservable skipWhile:^BOOL(NSNumber *x) {
            invoked++;
            return isPrime(x);
        }];
    }];

    NSArray *events = @[
            next(390, @4),
            next(410, @17),
            next(450, @8),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 470)
    ]);

    XCTAssertEqual(invoked, 6);
}

- (void)testSkipWhile_Zero {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90,  @(-1)),
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
            completed(600)
    ]];

    __block NSInteger invoked = 0;

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable skipWhile:^BOOL(NSNumber *x) {
        invoked++;
        return isPrime(x);
    }]];

    NSArray *events = @[
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
            completed(600)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 600)
    ]);

    XCTAssertEqual(invoked, 1);
}

- (void)testSkipWhile_Throw {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90,  @(-1)),
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable skipWhile:^BOOL(NSNumber *x) {
        invoked++;
        if (invoked == 3) {
            @throw testError();
        }
        return isPrime(x);
    }]];

    NSArray *events = @[
            error(290, testError()),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 290)
    ]);

    XCTAssertEqual(invoked, 3);
}

- (void)testSkipWhile_Index {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90,  @(-1)),
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
            completed(600)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable skipWhileWithIndex:^BOOL(NSNumber *x, NSUInteger index) {
        return index < 5;
    }]];

    NSArray *events = @[
            next(350, @7),
            next(390, @4),
            next(410, @17),
            next(450, @8),
            next(500, @23),
            completed(600)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 600)
    ]);
}

- (void)testSkipWhile_Index_Throw {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90,  @(-1)),
            next(110, @(-1)),
            next(205, @100),
            next(210, @2),
            next(260, @5),
            next(290, @13),
            next(320, @3),
            next(350, @7),
            next(390, @4),
            error(400, testError()),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable skipWhileWithIndex:^BOOL(NSNumber *x, NSUInteger index) {
        return index < 5;
    }]];

    NSArray *events = @[
            next(350, @7),
            next(390, @4),
            error(400, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 400)
    ]);
}

- (void)testSkipWhile_Index_SelectorThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(90,  @(-1)),
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable skipWhileWithIndex:^BOOL(NSNumber *x, NSUInteger index) {
        if (index < 5) {
            return YES;
        }
        @throw testError();
    }]];

    NSArray *events = @[
            error(350, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 350)
    ]);
}

@end

@implementation RxObservableStandardSequenceOperatorsTest (ElementAt)

- (void)testElementAt_Complete_After {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            completed(690)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable elementAt:10]];

    NSArray *events = @[
            next(460, @72),
            completed(460)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 460)
    ]);
}

- (void)testElementAt_Complete_Before {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            completed(320)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable elementAt:10]];

    NSArray *events = @[
            error(320, [RxError argumentOutOfRange])
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 320)
    ]);
}

- (void)testElementAt_Error_After {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            error(690, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable elementAt:10]];

    NSArray *events = @[
            next(460, @72),
            completed(460)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 460)
    ]);
}

- (void)testElementAt_Error_Before {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            error(310, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable elementAt:10]];

    NSArray *events = @[
            error(310, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 310)
    ]);
}

- (void)testElementAt_Dispose_Before {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            error(690, testError())
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:250 create:^RxObservable * {
        return [xs.asObservable elementAt:3];
    }];

    NSArray *events = @[
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 250)
    ]);
}

- (void)testElementAt_Dispose_After {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            next(410, @15),
            next(415, @16),
            next(460, @72),
            next(510, @76),
            next(560, @32),
            next(570, @(-100)),
            next(580, @(-3)),
            next(590, @5),
            next(630, @10),
            error(690, testError())
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:400 create:^RxObservable * {
        return [xs.asObservable elementAt:3];
    }];

    NSArray *events = @[
            next(280, @1),
            completed(280)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 280)
    ]);
}

- (void)testElementAt_First {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @6),
            next(150, @4),
            next(210, @9),
            next(230, @13),
            next(270, @7),
            next(280, @1),
            next(300, @(-1)),
            next(310, @3),
            next(340, @8),
            next(370, @11),
            completed(400)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable elementAt:0]];

    NSArray *events = @[
            next(210, @9),
            completed(210)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 210)
    ]);
}

@end

@implementation RxObservableStandardSequenceOperatorsTest (Single)

- (void)testSingle_Empty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable single]];

    NSArray *events = @[
            error(250, RxError.noElements)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 250)
    ]);
}

- (void)testSingle_One {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable single]];

    NSArray *events = @[
            next(210, @2),
            completed(250)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 250)
    ]);
}

- (void)testSingle_Many {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable single]];

    NSArray *events = @[
            next(210, @2),
            error(220, RxError.moreThanOneElement),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 220)
    ]);
}

- (void)testSingle_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            error(210, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable single]];

    NSArray *events = @[
            error(210, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 210)
    ]);
}

- (void)testSingle_DecrementCountsFirst {
    RxBehaviorSubject *k = [RxBehaviorSubject create:@NO];
    [[k single] subscribeNext:^(NSNumber *n) {
        [k onNext:@(!n.boolValue)];
    }];
}

- (void)testSinglePredicate_Empty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable single:^BOOL(NSNumber *element) {
        return element.integerValue % 2 == 1;
    }]];

    NSArray *events = @[
            error(250, RxError.noElements)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 250)
    ]);
}

- (void)testSinglePredicate_One {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable single:^BOOL(NSNumber *element) {
        return element.integerValue == 4;
    }]];

    NSArray *events = @[
            next(230, @4),
            completed(250)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 250)
    ]);
}

- (void)testSinglePredicate_Many {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable single:^BOOL(NSNumber *element) {
        return element.integerValue % 2 == 1;
    }]];

    NSArray *events = @[
            next(220, @3),
            error(240, RxError.moreThanOneElement)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 240)
    ]);
}

- (void)testSinglePredicate_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            error(210, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable single:^BOOL(NSNumber *element) {
        return element.integerValue % 2 == 1;
    }]];

    NSArray *events = @[
            error(210, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 210)
    ]);
}

- (void)testSinglePredicate_Throws {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable single:^BOOL(NSNumber *element) {
        if (element.integerValue < 4) {
            return NO;
        }
        @throw testError();
    }]];

    NSArray *events = @[
            error(230, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 230)
    ]);
}

- (void)testSinglePredicate_DecrementCountsFirst {
    RxBehaviorSubject *k = [RxBehaviorSubject create:@NO];
    [[k single:^BOOL(id o) {
        return YES;
    }] subscribeNext:^(NSNumber *n) {
        [k onNext:@(!n.boolValue)];
    }];
}

@end

#pragma clang diagnostic pop