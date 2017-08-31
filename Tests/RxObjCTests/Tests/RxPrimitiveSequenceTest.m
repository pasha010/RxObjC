//
//  RxPrimitiveSequenceTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 30.08.17.
//  Copyright © 2017 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RxTest.h"
#import <RxObjC/RxObjC.h>

@interface RxPrimitiveSequenceTest : RxTest

@end

@implementation RxPrimitiveSequenceTest
@end

@implementation RxPrimitiveSequenceTest (Single)

- (void)testSingle_Subscription_success {
    __auto_type xs = [RxSingle just:@1];

    __auto_type events = [NSMutableArray array];
    [xs subscribe:^(RxSingleEvent *event) {
        [events addObject:event];
    }];

    XCTAssertEqualObjects(events, @[[RxSingleEventSuccess create:@1]]);
}

- (void)testSingle_Subscription_error {
    __auto_type xs = [RxSingle error:testError()];
    __auto_type events = [NSMutableArray array];
    [xs subscribe:^(RxSingleEvent *event) {
        [events addObject:event];
    }];

    XCTAssertEqualObjects(events, @[[RxSingleEventError create:testError()]]);
}

- (void)testSingle_create_success {
    __auto_type scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block NSNumber *disposedTime = nil;

    __block void (^observer)(RxSingleEvent *) = nil;

    [scheduler scheduleAt:201 action:^{
        observer([RxSingleEventSuccess create:@1]);
    }];

    [scheduler scheduleAt:202 action:^{
        observer([RxSingleEventSuccess create:@1]);
    }];

    [scheduler scheduleAt:202 action:^{
        observer([RxSingleEventError create:testError()]);
    }];

    __auto_type res = [scheduler start:^RxObservable * {
        return [[RxSingle create:^id <RxDisposable>(RxSingleObserver _observer) {
            observer = _observer;
            return [RxAnonymousDisposable create:^{
                disposedTime = scheduler.clock;
            }];
        }] asObservable];
    }];

    __auto_type expect = @[next(201, @1), completed(201)];
    XCTAssertEqualObjects(res.events, expect);

    XCTAssertEqualObjects(disposedTime, @201);
}

- (void)testSingle_create_error {
    __auto_type scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block NSNumber *disposedTime = nil;
    __block void (^observer)(RxSingleEvent *) = nil;

    [scheduler scheduleAt:201 action:^{
        observer([RxSingleEventError create:testError()]);
    }];

    [scheduler scheduleAt:202 action:^{
        observer([RxSingleEventSuccess create:@1]);
    }];

    [scheduler scheduleAt:202 action:^{
        observer([RxSingleEventError create:testError()]);
    }];

    __auto_type res = [scheduler start:^RxObservable * {
        return [[RxSingle create:^id <RxDisposable>(RxSingleObserver _observer) {
            observer = _observer;
            return [RxAnonymousDisposable create:^{
                disposedTime = scheduler.clock;
            }];
        }] asObservable];
    }];

    __auto_type expect = @[error(201, testError())];
    XCTAssertEqualObjects(res.events, expect);

    XCTAssertEqualObjects(disposedTime, @201);
}

- (void)testSingle_create_disposing {
    __auto_type scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    __block NSNumber *disposedTime = nil;
    __block void (^observer)(RxSingleEvent *) = nil;
    __block id <RxDisposable> subscription = nil;

    __auto_type res = [scheduler createObserver];

    [scheduler scheduleAt:201 action:^{
        subscription = [[[RxSingle
                create:^id <RxDisposable>(RxSingleObserver _observer) {
                    observer = _observer;
                    return [RxAnonymousDisposable create:^{
                        disposedTime = scheduler.clock;
                    }];
                }]
                asObservable]
                subscribe:res];
    }];

    [scheduler scheduleAt:202 action:^{
        [subscription dispose];
    }];

    [scheduler scheduleAt:203 action:^{
        observer([RxSingleEventSuccess create:@1]);
    }];

    [scheduler scheduleAt:204 action:^{
        observer([RxSingleEventError create:testError()]);
    }];

    [scheduler start];

    XCTAssertEqualObjects(res.events, @[]);
    XCTAssertEqualObjects(disposedTime, @202);
}

- (void)testSingle_deferred_producesSingleElement {
    __auto_type result = [[RxSingle
                deferred:^RxPrimitiveSequence * {
                    return [RxSingle just:@1];
                }]
                toBlocking].first;

    XCTAssertEqualObjects(result, @1);
}

- (void)testSingle_just_producesSingleElement {
    __auto_type result = [[[RxSingle just:@1] toBlocking] first];
    XCTAssertEqualObjects(result, @1);
}

- (void)testSingle_just2_producesSingleElement {
    __auto_type result = [[RxSingle just:@1 scheduler:RxCurrentThreadScheduler.defaultInstance] toBlocking].first;
    XCTAssertEqualObjects(result, @1);
}

- (void)testSingle_error_fails {
    @try {
        id _ = [[RxSingle error:testError()] toBlocking].first;
        XCTFail(@"");

    } @catch (id e) {
        XCTAssertEqualObjects(e, testError());
    }
}

- (void)testSingle_never_producesSingleElement {
    __block RxSingleEvent *event = nil;
    __auto_type subscription = [[RxSingle never] subscribe:^(RxSingleEvent *_event) {
        event = _event;
    }];

    XCTAssertNil(event);
    [subscription dispose];
}

- (void)testSingle_delaySubscription_producesSingleElement {
    __auto_type scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    [scheduler start:^RxObservable * {
        return [[RxSingle just:@1] delaySubscription]];
    }]

    /*
     * let res = scheduler.start {
            (Single.just(1).delaySubscription(1.0, scheduler: scheduler) as Single<Int>).asObservable()
        }

        XCTAssertEqual(res.events, [
            next(201, 1),
            completed(201)
            ])

     */
}

@end
