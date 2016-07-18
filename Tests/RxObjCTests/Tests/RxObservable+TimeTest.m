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
