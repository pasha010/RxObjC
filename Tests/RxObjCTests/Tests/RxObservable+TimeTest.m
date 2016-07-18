//
//  RxObservable+TimeTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 10.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs throttle:20 scheduler:scheduler]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs throttle:20 scheduler:scheduler]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs throttle:40 scheduler:scheduler]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs throttle:40 scheduler:scheduler]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs throttle:10 scheduler:scheduler]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs throttle:10 scheduler:scheduler]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs throttle:10 scheduler:scheduler]];

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
            [xs throttle:20 scheduler:scheduler]];

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

    XCTAssertEqualWithAccuracy(2, [end timeIntervalSinceDate:start], 0.5);
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

    RxTestableObserver *res = [scheduler startWithObservable:[xs throttle:20 scheduler:scheduler]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs throttleFirst:20 scheduler:scheduler]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs throttleFirst:40 scheduler:scheduler]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs throttleFirst:40 scheduler:scheduler]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs throttleFirst:10 scheduler:scheduler]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs throttleFirst:10 scheduler:scheduler]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs throttleFirst:10 scheduler:scheduler]];

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
            [xs throttleFirst:20 scheduler:scheduler]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs sample:ys]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs sample:ys]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs sample:ys]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs sample:ys]];

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

    RxTestableObserver *res = [scheduler startWithObservable:[xs sample:ys]];

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
