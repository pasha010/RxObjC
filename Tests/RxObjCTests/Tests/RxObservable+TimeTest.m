//
//  RxObservable+TimeTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 10.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"
#import "RxPrimitiveMockObserver.h"
#import "RxEquatableArray.h"

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCDFAInspection"

@interface RxObservableTimeTest : RxTest
@end

@implementation RxObservableTimeTest
@end

@implementation RxObservableTimeTest (Throttle)

- (void)test_ThrottleTimeSpan_AllPass {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @0),
            next(210, @1),
            next(240, @2),
            next(270, @3),
            next(300, @4),
            completed(400)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable throttle:20 scheduler:scheduler]];

    NSArray *events = @[
            next(230, @1),
            next(260, @2),
            next(290, @3),
            next(320, @4),
            completed(400)
    ];
    XCTAssertEqualObjects(res.events, events);

    NSArray *subs = @[
            Subscription(200, 400)
    ];
    XCTAssertEqualObjects(xs.subscriptions, subs);
}

- (void)test_ThrottleTimeSpan_AllPass_ErrorEnd {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @0),
            next(210, @1),
            next(240, @2),
            next(270, @3),
            next(300, @4),
            error(400, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable throttle:20 scheduler:scheduler]];

    NSArray *events = @[
            next(230, @1),
            next(260, @2),
            next(290, @3),
            next(320, @4),
            error(400, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    NSArray *subs = @[
            Subscription(200, 400)
    ];
    XCTAssertEqualObjects(xs.subscriptions, subs);
}

- (void)test_ThrottleTimeSpan_AllDrop {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @0),
            next(210, @1),
            next(240, @2),
            next(270, @3),
            next(300, @4),
            next(330, @5),
            next(360, @6),
            next(390, @7),
            completed(400)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable throttle:40 scheduler:scheduler]];

    NSArray *events = @[
            next(400, @7),
            completed(400)
    ];
    XCTAssertEqualObjects(res.events, events);

    NSArray *subs = @[
            Subscription(200, 400)
    ];
    XCTAssertEqualObjects(xs.subscriptions, subs);
}

- (void)test_ThrottleTimeSpan_AllDrop_ErrorEnd {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @0),
            next(210, @1),
            next(240, @2),
            next(270, @3),
            next(300, @4),
            next(330, @5),
            next(360, @6),
            next(390, @7),
            error(400, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable throttle:40 scheduler:scheduler]];

    NSArray *events = @[
            error(400, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    NSArray *subs = @[
            Subscription(200, 400)
    ];
    XCTAssertEqualObjects(xs.subscriptions, subs);
}

- (void)test_ThrottleEmpty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @0),
            completed(300)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable throttle:10 scheduler:scheduler]];

    NSArray *events = @[
            completed(300)
    ];
    XCTAssertEqualObjects(res.events, events);

    NSArray *subs = @[
            Subscription(200, 300)
    ];
    XCTAssertEqualObjects(xs.subscriptions, subs);
}

- (void)test_ThrottleError {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @0),
            error(300, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable throttle:10 scheduler:scheduler]];

    NSArray *events = @[
            error(300, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    NSArray *subs = @[
            Subscription(200, 300)
    ];
    XCTAssertEqualObjects(xs.subscriptions, subs);
}

- (void)test_ThrottleNever {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @0),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable throttle:10 scheduler:scheduler]];

    NSArray *events = @[
    ];
    XCTAssertEqualObjects(res.events, events);

    NSArray *subs = @[
            Subscription(200, 1000)
    ];
    XCTAssertEqualObjects(xs.subscriptions, subs);
}

- (void)test_ThrottleSimple {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @0),
            next(210, @1),
            next(240, @2),
            next(250, @3),
            next(280, @4),
            completed(300)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable throttle:20 scheduler:scheduler]];

    NSArray *events = @[
            next(230, @1),
            next(270, @3),
            next(300, @4),
            completed(300)
    ];
    XCTAssertEqualObjects(res.events, events);

    NSArray *subs = @[
            Subscription(200, 300)
    ];
    XCTAssertEqualObjects(xs.subscriptions, subs);
}

- (void)test_ThrottleWithRealScheduler {
    RxConcurrentDispatchQueueScheduler *scheduler = [[RxConcurrentDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOS:[RxDispatchQueueSchedulerQOS default]];

    NSDate *start = [NSDate date];

    NSNumber *a = [[[[[@[[RxObservable just:@0], [RxObservable never]] toObservable] concat]
            throttle:2.0 scheduler:scheduler]
            toBlocking]
            blocking_first];

    NSDate *end = [NSDate date];

    XCTAssertEqualWithAccuracy(2, [end timeIntervalSinceDate:start], 0.6);
    XCTAssertEqualObjects(a, @0);
}

@end

@implementation RxObservableTimeTest (ThrottleFirst)

- (void)test_ThrottleFirstTimeSpan_AllPass {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @0),
            next(210, @1),
            next(240, @2),
            next(270, @3),
            next(300, @4),
            completed(400)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable throttle:20 scheduler:scheduler]];

    NSArray *events = @[
            next(230, @1),
            next(260, @2),
            next(290, @3),
            next(320, @4),
            completed(400)
    ];
    XCTAssertEqualObjects(res.events, events);

    NSArray *subs = @[
            Subscription(200, 400)
    ];
    XCTAssertEqualObjects(xs.subscriptions, subs);
}

- (void)test_ThrottleFirstTimeSpan_AllPass_ErrorEnd {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @0),
            next(210, @1),
            next(240, @2),
            next(270, @3),
            next(300, @4),
            error(400, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable throttleFirst:20 scheduler:scheduler]];

    NSArray *events = @[
            next(230, @1),
            next(260, @2),
            next(290, @3),
            next(320, @4),
            error(400, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    NSArray *subs = @[
            Subscription(200, 400)
    ];
    XCTAssertEqualObjects(xs.subscriptions, subs);
}

- (void)test_ThrottleFirstTimeSpan_AllDrop {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @0),
            next(210, @1),
            next(240, @2),
            next(270, @3),
            next(300, @4),
            next(330, @5),
            next(360, @6),
            next(390, @7),
            completed(400)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable throttleFirst:40 scheduler:scheduler]];

    NSArray *events = @[
            next(400, @1),
            completed(400)
    ];
    XCTAssertEqualObjects(res.events, events);

    NSArray *subs = @[
            Subscription(200, 400)
    ];
    XCTAssertEqualObjects(xs.subscriptions, subs);
}

- (void)test_ThrottleFirstTimeSpan_AllDrop_ErrorEnd {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @0),
            next(210, @1),
            next(240, @2),
            next(270, @3),
            next(300, @4),
            next(330, @5),
            next(360, @6),
            next(390, @7),
            error(400, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable throttleFirst:40 scheduler:scheduler]];

    NSArray *events = @[
            error(400, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    NSArray *subs = @[
            Subscription(200, 400)
    ];
    XCTAssertEqualObjects(xs.subscriptions, subs);
}

- (void)test_ThrottleFirstEmpty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @0),
            completed(300)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable throttleFirst:10 scheduler:scheduler]];

    NSArray *events = @[
            completed(300)
    ];
    XCTAssertEqualObjects(res.events, events);

    NSArray *subs = @[
            Subscription(200, 300)
    ];
    XCTAssertEqualObjects(xs.subscriptions, subs);
}

- (void)test_ThrottleFirstError {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @0),
            error(300, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable throttleFirst:10 scheduler:scheduler]];

    NSArray *events = @[
            error(300, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    NSArray *subs = @[
            Subscription(200, 300)
    ];
    XCTAssertEqualObjects(xs.subscriptions, subs);
}

- (void)test_ThrottleFirstNever {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @0),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable throttleFirst:10 scheduler:scheduler]];

    NSArray *events = @[
    ];
    XCTAssertEqualObjects(res.events, events);

    NSArray *subs = @[
            Subscription(200, 1000)
    ];
    XCTAssertEqualObjects(xs.subscriptions, subs);
}

- (void)test_ThrottleFirstSimple {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @0),
            next(210, @1),
            next(240, @2),
            next(250, @3),
            next(280, @4),
            completed(300)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable throttleFirst:20 scheduler:scheduler]];

    NSArray *events = @[
            next(230, @1),
            next(270, @2),
            next(300, @4),
            completed(300)
    ];
    XCTAssertEqualObjects(res.events, events);

    NSArray *subs = @[
            Subscription(200, 300)
    ];
    XCTAssertEqualObjects(xs.subscriptions, subs);
}

- (void)test_ThrottleFirstWithRealScheduler {
    RxConcurrentDispatchQueueScheduler *scheduler = [[RxConcurrentDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOS:[RxDispatchQueueSchedulerQOS default]];

    NSDate *start = [NSDate date];

    NSNumber *a = [[[[[@[[RxObservable just:@0], [RxObservable just:@2], [RxObservable never]] toObservable] concat]
            throttleFirst:2.0 scheduler:scheduler]
            toBlocking]
            blocking_first];

    NSDate *end = [NSDate date];

    XCTAssertEqualWithAccuracy(2, [end timeIntervalSinceDate:start], 0.5);
    XCTAssertEqualObjects(a, @0);
}

@end

@implementation RxObservableTimeTest (Sample)

- (void)testSample_Sampler_SamplerThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(220, @2),
            next(240, @3),
            next(290, @4),
            next(300, @5),
            next(310, @6),
            completed(400)
    ]];

    RxTestableObservable *ys = [scheduler createHotObservable:@[
            next(150, @""),
            next(210, @"bar"),
            next(250, @"foo"),
            next(260, @"qux"),
            error(320, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable sample:ys]];

    NSArray *events = @[
            next(250, @3),
            error(320, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 320)
    ]);
    XCTAssertEqualObjects(ys.subscriptions, @[
            Subscription(200, 320)
    ]);
}

- (void)testSample_Sampler_Simple1 {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(220, @2),
            next(240, @3),
            next(290, @4),
            next(300, @5),
            next(310, @6),
            completed(400)
    ]];

    RxTestableObservable *ys = [scheduler createHotObservable:@[
            next(150, @""),
            next(210, @"bar"),
            next(250, @"foo"),
            next(260, @"qux"),
            next(320, @"baz"),
            completed(500)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable sample:ys]];

    NSArray *events = @[
            next(250, @3),
            next(320, @6),
            completed(500),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 400)
    ]);
    XCTAssertEqualObjects(ys.subscriptions, @[
            Subscription(200, 500)
    ]);
}

- (void)testSample_Sampler_Simple2 {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(220, @2),
            next(240, @3),
            next(290, @4),
            next(300, @5),
            next(310, @6),
            next(360, @7),
            completed(400)
    ]];

    RxTestableObservable *ys = [scheduler createHotObservable:@[
            next(150, @""),
            next(210, @"bar"),
            next(250, @"foo"),
            next(260, @"qux"),
            next(320, @"baz"),
            completed(500)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable sample:ys]];

    NSArray *events = @[
            next(250, @3),
            next(320, @6),
            next(500, @7),
            completed(500)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 400)
    ]);
    XCTAssertEqualObjects(ys.subscriptions, @[
            Subscription(200, 500)
    ]);
}

- (void)testSample_Sampler_Simple3 {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(220, @2),
            next(240, @3),
            next(290, @4),
            completed(300)
    ]];

    RxTestableObservable *ys = [scheduler createHotObservable:@[
            next(150, @""),
            next(210, @"bar"),
            next(250, @"foo"),
            next(260, @"qux"),
            next(320, @"baz"),
            completed(500)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable sample:ys]];

    NSArray *events = @[
            next(250, @3),
            next(320, @4),
            completed(320)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 300)
    ]);
    XCTAssertEqualObjects(ys.subscriptions, @[
            Subscription(200, 320)
    ]);
}

- (void)testSample_Sampler_SourceThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(220, @2),
            next(240, @3),
            next(290, @4),
            next(300, @5),
            next(310, @6),
            error(320, testError())
    ]];

    RxTestableObservable *ys = [scheduler createHotObservable:@[
            next(150, @""),
            next(210, @"bar"),
            next(250, @"foo"),
            next(260, @"qux"),
            next(300, @"baz"),
            completed(400)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable sample:ys]];

    NSArray *events = @[
            next(250, @3),
            next(300, @5),
            error(320, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 320)
    ]);
    XCTAssertEqualObjects(ys.subscriptions, @[
            Subscription(200, 320)
    ]);
}

@end

@implementation RxObservableTimeTest (Interval)

- (void)testInterval_TimeSpan_Basic {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler startWithObservable:
            [RxObservable interval:100 scheduler:scheduler]];

    NSArray *events = @[
            next(300, @0),
            next(400, @1),
            next(500, @2),
            next(600, @3),
            next(700, @4),
            next(800, @5),
            next(900, @6)
    ];
    XCTAssertEqualObjects(res.events, events);
}

- (void)testInterval_TimeSpan_Zero {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler startWhenDisposed:210 create:^RxObservable * {
        return [RxObservable interval:0 scheduler:scheduler];
    }];

    NSArray *events = @[
            next(201, @0),
            next(202, @1),
            next(203, @2),
            next(204, @3),
            next(205, @4),
            next(206, @5),
            next(207, @6),
            next(208, @7),
            next(209, @8),
    ];
    XCTAssertEqualObjects(res.events, events);
}

- (void)testInterval_TimeSpan_Zero_DefaultScheduler {
    RxSerialDispatchQueueScheduler *scheduler = [[RxSerialDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOS:[RxDispatchQueueSchedulerQOS default]];

    RxPrimitiveMockObserver *observer = [[RxPrimitiveMockObserver alloc] init];

    XCTestExpectation *expectation = [self expectationWithDescription:@"It will complete"];

    id <RxDisposable> d = [[[RxObservable interval:0 scheduler:scheduler] takeWhile:^BOOL(NSNumber *element) {
        return element.integerValue < 10;
    }] subscribeOnNext:^(NSNumber *element) {
        [observer onNext:element];
    } onCompleted:^{
        [expectation fulfill];
    }];

    @onExit {
        [d dispose];
    };

    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError *error) {
        XCTAssert(error == nil, @"Did not complete");
    }];

    XCTestExpectation *cleanResources = [self expectationWithDescription:@"cleanResources"];

    [scheduler schedule:nil action:^id <RxDisposable>(RxStateType o) {
        [cleanResources fulfill];
        return [RxNopDisposable sharedInstance];
    }];

    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError *error) {
        XCTAssert(error == nil, @"Did not clean up");
    }];

    XCTAssertTrue(observer.events.count == 10);
}

- (void)testInterval_TimeSpan_Disposed {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler startWithObservable:
            [RxObservable interval:1000 scheduler:scheduler]];

    NSArray *events = @[
    ];
    XCTAssertEqualObjects(res.events, events);
}

- (void)test_IntervalWithRealScheduler {
    RxConcurrentDispatchQueueScheduler *scheduler = [[RxConcurrentDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOS:[RxDispatchQueueSchedulerQOS default]];

    NSDate *start = [NSDate date];

    NSArray<NSNumber *> *a = [[[[RxObservable interval:1 scheduler:scheduler]
            take:2]
            toBlocking]
            blocking_toArray];

    NSDate *end = [NSDate date];

    XCTAssertEqualWithAccuracy(2, [end timeIntervalSinceDate:start], 0.5);

    NSArray *array = @[@0, @1];
    XCTAssertEqualObjects(a, array);
}

@end

@implementation RxObservableTimeTest (Take)

- (void)testTake_TakeZero {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(210, @1),
            next(220, @2),
            completed(230)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable take:0 scheduler:scheduler]];

    NSArray *events = @[
            completed(201)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 201)
    ]);
}

- (void)testTake_Some {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(210, @1),
            next(220, @2),
            next(230, @3),
            completed(240)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable take:25 scheduler:scheduler]];

    NSArray *events = @[
            next(210, @1),
            next(220, @2),
            completed(225)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 225)
    ]);
}

- (void)testTake_TakeLate {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(210, @1),
            next(220, @2),
            completed(230),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable take:50 scheduler:scheduler]];

    NSArray *events = @[
            next(210, @1),
            next(220, @2),
            completed(230)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 230)
    ]);
}

- (void)testTake_TakeError {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(0, @0),
            error(210, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable take:50 scheduler:scheduler]];

    NSArray *events = @[
            error(210, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 210)
    ]);
}

- (void)testTake_TakeNever {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(0, @0),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable take:50 scheduler:scheduler]];

    NSArray *events = @[
            completed(250)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 250)
    ]);
}

- (void)testTake_TakeTwice1 {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(210, @1),
            next(220, @2),
            next(230, @3),
            next(240, @4),
            next(250, @5),
            next(260, @6),
            completed(270)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [[xs.asObservable take:55 scheduler:scheduler] take:35 scheduler:scheduler]
    ];

    NSArray *events = @[
            next(210, @1),
            next(220, @2),
            next(230, @3),
            completed(235)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 235)
    ]);
}

- (void)testTake_TakeDefault {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(210, @1),
            next(220, @2),
            next(230, @3),
            next(240, @4),
            next(250, @5),
            next(260, @6),
            completed(270)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable take:35 scheduler:scheduler]];

    NSArray *events = @[
            next(210, @1),
            next(220, @2),
            next(230, @3),
            completed(235)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 235)
    ]);
}

@end

@implementation RxObservableTimeTest (DelaySubscription)

- (void)testDelaySubscription_TimeSpan_Simple {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            next(50, @42),
            next(60, @43),
            completed(70)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable delaySubscription:30 scheduler:scheduler]];

    NSArray *events = @[
            next(280, @42),
            next(290, @43),
            completed(300)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(230, 300)
    ]);
}

- (void)testDelaySubscription_TimeSpan_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            next(50, @42),
            next(60, @43),
            error(70, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable delaySubscription:30 scheduler:scheduler]];

    NSArray *events = @[
            next(280, @42),
            next(290, @43),
            error(300, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(230, 300)
    ]);
}

- (void)testDelaySubscription_TimeSpan_Dispose {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            next(50, @42),
            next(60, @43),
            error(70, testError())
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:291 create:^RxObservable * {
        return [xs.asObservable delaySubscription:30 scheduler:scheduler];
    }];

    NSArray *events = @[
            next(280, @42),
            next(290, @43),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(230, 291)
    ]);
}

@end

@implementation RxObservableTimeTest (Skip)

- (void)testSkip_Zero {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(210, @1),
            next(220, @2),
            completed(230)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable skip:0 scheduler:scheduler]];

    NSArray *events = @[
            next(210, @1),
            next(220, @2),
            completed(230)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 230)
    ]);
}

- (void)testSkip_Some {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(210, @1),
            next(220, @2),
            completed(230)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable skip:15 scheduler:scheduler]];

    NSArray *events = @[
            next(220, @2),
            completed(230)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 230)
    ]);
}

- (void)testSkip_Late {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(210, @1),
            next(220, @2),
            completed(230)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable skip:50 scheduler:scheduler]];

    NSArray *events = @[
            completed(230)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 230)
    ]);
}

- (void)testSkip_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            error(210, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable skip:50 scheduler:scheduler]];

    NSArray *events = @[
            error(210, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 210)
    ]);
}

- (void)testSkip_Never {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable skip:50 scheduler:scheduler]];

    NSArray *events = @[
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 1000)
    ]);
}

@end

@implementation RxObservableTimeTest (IgnoreElements)

- (void)testIgnoreElements_DoesNotSendValues {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(210, @1),
            next(220, @2),
            completed(230)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable ignoreElements]];

    NSArray *events = @[
            completed(230)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 230)
    ]);
}

@end

@implementation RxObservableTimeTest (Buffer)

- (void)testBufferWithTimeOrCount_Basic {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(205, @1),
            next(210, @2),
            next(240, @3),
            next(280, @4),
            next(320, @5),
            next(350, @6),
            next(370, @7),
            next(420, @8),
            next(470, @9),
            completed(600)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [[xs.asObservable buffer:70 count:3 scheduler:scheduler]
                    map:^RxEquatableArray *(NSArray *array) {
                        return [[RxEquatableArray alloc] initWithElements:array];
                    }]];

    NSArray *events = @[
            next(240, EquatableArray(@[@1, @2, @3])),
            next(310, EquatableArray(@[@4])),
            next(370, EquatableArray(@[@5, @6, @7])),
            next(440, EquatableArray(@[@8])),
            next(510, EquatableArray(@[@9])),
            next(580, EquatableArray(@[])),
            next(600, EquatableArray(@[])),
            completed(600)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 600)
    ]);
}

- (void)testBufferWithTimeOrCount_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(205, @1),
            next(210, @2),
            next(240, @3),
            next(280, @4),
            next(320, @5),
            next(350, @6),
            next(370, @7),
            next(420, @8),
            next(470, @9),
            error(600, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [[xs.asObservable buffer:70 count:3 scheduler:scheduler]
                    map:^RxEquatableArray *(NSArray *array) {
                        return [[RxEquatableArray alloc] initWithElements:array];
                    }]];

    NSArray *events = @[
            next(240, EquatableArray(@[@1, @2, @3])),
            next(310, EquatableArray(@[@4])),
            next(370, EquatableArray(@[@5, @6, @7])),
            next(440, EquatableArray(@[@8])),
            next(510, EquatableArray(@[@9])),
            next(580, EquatableArray(@[])),
            error(600, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 600)
    ]);
}

- (void)testBufferWithTimeOrCount_Disposed {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(205, @1),
            next(210, @2),
            next(240, @3),
            next(280, @4),
            next(320, @5),
            next(350, @6),
            next(370, @7),
            next(420, @8),
            next(470, @9),
            completed(600)
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:370 create:^RxObservable * {
        return [[xs.asObservable buffer:70 count:3 scheduler:scheduler]
                map:^RxEquatableArray *(NSArray *array) {
                    return [[RxEquatableArray alloc] initWithElements:array];
                }];
    }];

    NSArray *events = @[
            next(240, EquatableArray(@[@1, @2, @3])),
            next(310, EquatableArray(@[@4])),
            next(370, EquatableArray(@[@5, @6, @7])),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 370)
    ]);
}

- (void)testBufferWithTimeOrCount_Default {
    RxSerialDispatchQueueScheduler *backgroundScheduler = [[RxSerialDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOS:[RxDispatchQueueSchedulerQOS default]];

    NSArray<NSNumber *> *result = [[[[[RxObservable range:1 count:10 scheduler:backgroundScheduler]
            buffer:1000 count:3 scheduler:backgroundScheduler]
            skip:1]
            toBlocking]
            blocking_first];

    NSArray *array = @[@4, @5, @6];
    XCTAssertEqualObjects(result, array);
}

@end

@implementation RxObservableTimeTest (Window)

- (void)testWindowWithTimeOrCount_Basic {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(205, @1),
            next(210, @2),
            next(240, @3),
            next(280, @4),
            next(320, @5),
            next(350, @6),
            next(370, @7),
            next(420, @8),
            next(470, @9),
            completed(600)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        RxObservable<RxObservable *> *window = [xs.asObservable window:70 count:3 scheduler:scheduler];
        RxObservable<NSString *> *mapWithIndex = [window mapWithIndex:^RxObservable<NSString *> *(RxObservable<NSNumber *> *o, NSInteger index) {
            return [o map:^NSString *(NSNumber *element) {
                return [NSString stringWithFormat:@"%zd %@", index, element];
            }];
        }];

        return [mapWithIndex merge];
    }];

    NSArray *events = @[
            next(205, @"0 1"),
            next(210, @"0 2"),
            next(240, @"0 3"),
            next(280, @"1 4"),
            next(320, @"2 5"),
            next(350, @"2 6"),
            next(370, @"2 7"),
            next(420, @"3 8"),
            next(470, @"4 9"),
            completed(600)
    ];
    XCTAssertEqualObjects(res.events, events);
    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 600)
    ]);
}

- (void)testWindowWithTimeOrCount_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(205, @1),
            next(210, @2),
            next(240, @3),
            next(280, @4),
            next(320, @5),
            next(350, @6),
            next(370, @7),
            next(420, @8),
            next(470, @9),
            error(600, testError())
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        RxObservable<RxObservable *> *window = [xs.asObservable window:70 count:3 scheduler:scheduler];
        RxObservable<NSString *> *mapWithIndex = [window mapWithIndex:^RxObservable<NSString *> *(RxObservable<NSNumber *> *o, NSInteger index) {
            return [o map:^NSString *(NSNumber *element) {
                return [NSString stringWithFormat:@"%zd %@", index, element];
            }];
        }];

        return [mapWithIndex merge];
    }];

    NSArray *events = @[
            next(205, @"0 1"),
            next(210, @"0 2"),
            next(240, @"0 3"),
            next(280, @"1 4"),
            next(320, @"2 5"),
            next(350, @"2 6"),
            next(370, @"2 7"),
            next(420, @"3 8"),
            next(470, @"4 9"),
            error(600, testError())
    ];
    XCTAssertEqualObjects(res.events, events);
    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 600)
    ]);
}

- (void)testWindowWithTimeOrCount_Disposed {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(105, @0),
            next(205, @1),
            next(210, @2),
            next(240, @3),
            next(280, @4),
            next(320, @5),
            next(350, @6),
            next(370, @7),
            next(420, @8),
            next(470, @9),
            completed(600)
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:370 create:^RxObservable * {
        RxObservable<RxObservable *> *window = [xs.asObservable window:70 count:3 scheduler:scheduler];
        RxObservable<NSString *> *mapWithIndex = [window mapWithIndex:^RxObservable<NSString *> *(RxObservable<NSNumber *> *o, NSInteger index) {
            return [o map:^NSString *(NSNumber *element) {
                return [NSString stringWithFormat:@"%zd %@", index, element];
            }];
        }];

        return [mapWithIndex merge];
    }];

    NSArray *events = @[
            next(205, @"0 1"),
            next(210, @"0 2"),
            next(240, @"0 3"),
            next(280, @"1 4"),
            next(320, @"2 5"),
            next(350, @"2 6"),
            next(370, @"2 7")
    ];
    XCTAssertEqualObjects(res.events, events);
    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 370)
    ]);
}

- (void)testWindowWithTimeOrCount_BasicPeriod {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(240, @3),
            next(270, @4),
            next(320, @5),
            next(360, @6),
            next(390, @7),
            next(410, @8),
            next(460, @9),
            next(470, @10),
            completed(490)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        RxObservable<RxObservable *> *window = [xs.asObservable window:70 count:3 scheduler:scheduler];
        RxObservable<NSString *> *mapWithIndex = [window mapWithIndex:^RxObservable<NSString *> *(RxObservable<NSNumber *> *o, NSInteger index) {
            return [[o map:^NSString *(NSNumber *element) {
                return [NSString stringWithFormat:@"%zd %@", index, element];
            }] concatWith:[RxObservable just:[NSString stringWithFormat:@"%zd end", index]]];
        }];

        return [mapWithIndex merge];
    }];

    NSArray *events = @[
            next(210, @"0 2"),
            next(240, @"0 3"),
            next(270, @"0 4"),
            next(270, @"0 end"),
            next(320, @"1 5"),
            next(340, @"1 end"),
            next(360, @"2 6"),
            next(390, @"2 7"),
            next(410, @"2 8"),
            next(410, @"2 end"),
            next(460, @"3 9"),
            next(470, @"3 10"),
            next(480, @"3 end"),
            next(490, @"4 end"),
            completed(490)
    ];
    XCTAssertEqualObjects(res.events, events);
    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 490)
    ]);
}

- (void)testWindowWithTimeOrCount_Default {
    RxSerialDispatchQueueScheduler *backgroundScheduler = [[RxSerialDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOS:[RxDispatchQueueSchedulerQOS default]];

    NSString *result = [[[[[[[RxObservable range:1 count:10 scheduler:backgroundScheduler]
            window:1000 count:3 scheduler:backgroundScheduler]
            mapWithIndex:^RxObservable<NSString *> *(RxObservable<NSNumber *> *o, NSInteger index) {
                return [o map:^NSString *(NSNumber *element) {
                    return [NSString stringWithFormat:@"%zd %@", index, element];
                }];
            }]
            merge]
            skip:4]
            toBlocking]
            blocking_first];

    XCTAssertEqualObjects(result, @"1 5");
}

@end


@implementation RxObservableTimeTest (Timeout)

- (void)testTimeout_Empty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @0),
            completed(300)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs.asObservable timeout:200 scheduler:scheduler]];

    NSArray *events = @[
            completed(300),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 300)
    ]);
}

- (void)testTimeout_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @0),
            error(300, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable timeout:200 scheduler:scheduler]];

    NSArray *events = @[
            error(300, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 300)
    ]);
}

- (void)testTimeout_Never {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @0),
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable timeout:1000 scheduler:scheduler]];

    NSArray *events = @[
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 1000)
    ]);
}

- (void)testTimeout_Duetime_Simple {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            next(10, @42),
            next(25, @43),
            next(40, @44),
            next(50, @45),
            completed(60)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable timeout:30 scheduler:scheduler]];

    NSArray *events = @[
            next(210, @42),
            next(225, @43),
            next(240, @44),
            next(250, @45),
            completed(260)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 260)
    ]);
}

- (void)testTimeout_Duetime_Timeout_Exact {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            next(10, @42),
            next(20, @43),
            next(50, @44),
            next(60, @45),
            completed(70)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable timeout:30 scheduler:scheduler]];

    NSArray *events = @[
            next(210, @42),
            next(220, @43),
            next(250, @44),
            next(260, @45),
            completed(270)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 270)
    ]);
}

- (void)testTimeout_Duetime_Timeout {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            next(10, @42),
            next(20, @43),
            next(50, @44),
            next(60, @45),
            completed(70)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable timeout:25 scheduler:scheduler]];

    NSArray *events = @[
            next(210, @42),
            next(220, @43),
            error(245, RxError.timeout)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 245)
    ]);
}

- (void)testTimeout_Duetime_Disposed {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(205, @1),
            next(210, @2),
            next(240, @3),
            next(280, @4),
            next(320, @5),
            next(350, @6),
            next(370, @7),
            next(420, @8),
            next(470, @9),
            completed(600)
    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:370 create:^RxObservable * {
        return [xs.asObservable timeout:40 scheduler:scheduler];
    }];

    NSArray *events = @[
            next(205, @1),
            next(210, @2),
            next(240, @3),
            next(280, @4),
            next(320, @5),
            next(350, @6),
            next(370, @7)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 370)
    ]);
}

- (void)testTimeout_TimeoutOccurs_1 {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @1),
            next(130, @2),
            next(310, @3),
            next(400, @4),
            completed(500)
    ]];

    RxTestableObservable *ys = [scheduler createColdObservable:@[
            next(50,  @(-1)),
            next(200, @(-2)),
            next(310, @(-3)),
            completed(320)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable timeout:100 other:ys scheduler:scheduler]];

    NSArray *events = @[
            next(350, @(-1)),
            next(500, @(-2)),
            next(610, @(-3)),
            completed(620)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 300)
    ]);

    XCTAssertEqualObjects(ys.subscriptions, @[
            Subscription(300, 620)
    ]);
}

- (void)testTimeout_TimeoutOccurs_2 {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @1),
            next(130, @2),
            next(240, @3),
            next(310, @4),
            next(430, @5),
            completed(500)
    ]];

    RxTestableObservable *ys = [scheduler createColdObservable:@[
            next(50,  @(-1)),
            next(200, @(-2)),
            next(310, @(-3)),
            completed(320)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable timeout:100 other:ys scheduler:scheduler]];

    NSArray *events = @[
            next(240, @3),
            next(310, @4),
            next(460, @(-1)),
            next(610, @(-2)),
            next(720, @(-3)),
            completed(730)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 410)
    ]);

    XCTAssertEqualObjects(ys.subscriptions, @[
            Subscription(410, 730)
    ]);
}

- (void)testTimeout_TimeoutOccurs_Never {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @1),
            next(130, @2),
            next(240, @3),
            next(310, @4),
            next(430, @5),
            completed(500)
    ]];

    RxTestableObservable *ys = [scheduler createColdObservable:@[
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable timeout:100 other:ys scheduler:scheduler]];

    NSArray *events = @[
            next(240, @3),
            next(310, @4),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 410)
    ]);

    XCTAssertEqualObjects(ys.subscriptions, @[
            Subscription(410, 1000)
    ]);
}

- (void)testTimeout_TimeoutOccurs_Completed {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            completed(500)
    ]];

    RxTestableObservable *ys = [scheduler createColdObservable:@[
            next(100, @(-1))
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable timeout:100 other:ys scheduler:scheduler]];

    NSArray *events = @[
            next(400, @(-1)),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 300)
    ]);

    XCTAssertEqualObjects(ys.subscriptions, @[
            Subscription(300, 1000)
    ]);
}

- (void)testTimeout_TimeoutOccurs_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            error(500, testError())
    ]];

    RxTestableObservable *ys = [scheduler createColdObservable:@[
            next(100, @(-1))
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable timeout:100 other:ys scheduler:scheduler]];

    NSArray *events = @[
            next(400, @(-1)),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 300)
    ]);

    XCTAssertEqualObjects(ys.subscriptions, @[
            Subscription(300, 1000)
    ]);
}

- (void)testTimeout_TimeoutOccurs_NextIsError {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(500, @42)
    ]];

    RxTestableObservable *ys = [scheduler createColdObservable:@[
            error(100, testError())
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable timeout:100 other:ys scheduler:scheduler]];

    NSArray *events = @[
            error(400, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 300)
    ]);

    XCTAssertEqualObjects(ys.subscriptions, @[
            Subscription(300, 400)
    ]);
}

- (void)testTimeout_TimeoutNotOccurs_Completed {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            completed(250)
    ]];

    RxTestableObservable *ys = [scheduler createColdObservable:@[
            next(100, @(-1))
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable timeout:100 other:ys scheduler:scheduler]];

    NSArray *events = @[
            completed(250)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 250)
    ]);

    XCTAssertEqualObjects(ys.subscriptions, @[
    ]);
}

- (void)testTimeout_TimeoutNotOccurs_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            error(250, testError())
    ]];

    RxTestableObservable *ys = [scheduler createColdObservable:@[
            next(100, @(-1))
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable timeout:100 other:ys scheduler:scheduler]];

    NSArray *events = @[
            error(250, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 250)
    ]);

    XCTAssertEqualObjects(ys.subscriptions, @[
    ]);
}

- (void)testTimeout_TimeoutNotOccurs {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(70,  @1),
            next(130, @2),
            next(240, @3),
            next(320, @4),
            next(410, @5),
            completed(500)
    ]];

    RxTestableObservable *ys = [scheduler createColdObservable:@[
            next(50,  @(-1)),
            next(200, @(-2)),
            next(310, @(-3)),
            completed(320)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:
            [xs.asObservable timeout:100 other:ys scheduler:scheduler]];

    NSArray *events = @[
            next(240, @3),
            next(320, @4),
            next(410, @5),
            completed(500)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 500)
    ]);

    XCTAssertEqualObjects(ys.subscriptions, @[
    ]);
}

@end

#pragma clang diagnostic pop
