//
//  RxSingleTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 01.09.17.
//  Copyright © 2017 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RxTest.h"
#import <RxObjC/RxObjC.h>

@interface RxSingleTest : XCTestCase
@end

@implementation RxSingleTest

- (void)testSingle_Subscription_success {
    __auto_type xs = [RxSingle just:@1];

    __auto_type events = [NSMutableArray array];
    [xs subscribeOnSuccess:^(id o) {
        [events addObject:o];
    }];

    XCTAssertEqualObjects(events, @[@1]);
}

- (void)testSingle_Subscription_error {
    __auto_type xs = [RxSingle error:testError()];
    __auto_type events = [NSMutableArray array];
    [xs subscribeOnSuccess:nil onError:^(NSError *error) {
        [events addObject:error];
    }];

    XCTAssertEqualObjects(events, @[testError()]);
}

- (void)testSingle_create_success {
    __auto_type scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block NSNumber *disposedTime = nil;

    __block id <RxSingleObserver> observer = nil;

    [scheduler scheduleAt:201 action:^{
        [observer onSuccess:@1];
    }];

    [scheduler scheduleAt:202 action:^{
        [observer onSuccess:@1];
    }];

    [scheduler scheduleAt:202 action:^{
        [observer onError:testError()];
    }];

    __auto_type res = [scheduler start:^RxObservable * {
        return [[RxSingle create:^id <RxDisposable>(id <RxSingleObserver> _observer) {
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
    __block id <RxSingleObserver> observer = nil;

    [scheduler scheduleAt:201 action:^{
        [observer onError:testError()];
    }];

    [scheduler scheduleAt:202 action:^{
        [observer onSuccess:@1];
    }];

    [scheduler scheduleAt:202 action:^{
        [observer onError:testError()];
    }];

    __auto_type res = [scheduler start:^RxObservable * {
        return [[RxSingle create:^id <RxDisposable>(id <RxSingleObserver> _observer) {
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
    __block id <RxSingleObserver> observer = nil;
    __block id <RxDisposable> subscription = nil;

    __auto_type res = [scheduler createObserver];

    [scheduler scheduleAt:201 action:^{
        subscription = [[[RxSingle
                create:^id <RxDisposable>(id <RxSingleObserver> _observer) {
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
        [observer onSuccess:@1];
    }];

    [scheduler scheduleAt:204 action:^{
        [observer onError:testError()];
    }];

    [scheduler start];

    XCTAssertEqualObjects(res.events, @[]);
    XCTAssertEqualObjects(disposedTime, @202);
}

- (void)testSingle_deferred_producesSingleElement {
    RxSingle *result = [[RxSingle
            deferred:^RxPrimitiveSequence * {
                return [RxSingle just:@1];
            }]
            toBlocking].first;

    XCTAssertEqualObjects(result, @1);
}

- (void)testSingle_just_producesSingleElement {
    RxSingle *result = [[[RxSingle just:@1] toBlocking] first];
    XCTAssertEqualObjects(result, @1);
}

- (void)testSingle_just2_producesSingleElement {
    RxSingle *result = [[RxSingle just:@1 scheduler:RxCurrentThreadScheduler.defaultInstance] toBlocking].first;
    XCTAssertEqualObjects(result, @1);
}

- (void)testSingle_error_fails {
    @try {
        id __unused _ = [[RxSingle error:testError()] toBlocking].first;
        XCTFail(@"");
    } @catch (id e) {
        XCTAssertEqualObjects(e, testError());
    }
}

- (void)testSingle_never_producesSingleElement {
    __block id element = nil;
    __block NSError *error = nil;
    __auto_type subscription = [[RxSingle never] subscribeOnSuccess:^(id o) {
        element = o;
    } onError:^(NSError *_error) {
        error = _error;
    }];

    XCTAssertNil(element);
    XCTAssertNil(error);
    [subscription dispose];
}

- (void)testSingle_delaySubscription_producesSingleElement {
    __auto_type scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __auto_type res = [scheduler start:^RxObservable * {
        return [[[RxSingle just:@1] delaySubscription:1.0 scheduler:scheduler] asObservable];
    }];

    __auto_type expected = @[next(201, @1), completed(201)];

    XCTAssertEqualObjects(res.events, expected);
}

- (void)testSingle_do_producesSingleElement {
    RxSingle *single = [[RxSingle just:@1] doOnNext:nil onError:nil onCompleted:nil];
    __auto_type result = [single toBlocking].first;
    XCTAssertEqualObjects(result, @1);
}

- (void)testSingle_filter_resultIsMaybe {
    __auto_type res = [[[RxSingle
            just:@1]
            filter:^BOOL(id o) {
                return NO;
            }]
            toBlocking].first;
    XCTAssertNil(res);
}

- (void)testSingle_map_producesSingleElement {
    id res = [[[RxSingle
            just:@1]
            map:^NSNumber *(NSNumber *o) {
                return @(o.integerValue * 2);
            }]
            toBlocking].first;

    XCTAssertEqualObjects(res, @2);
}

- (void)testSingle_flatMap_producesSingleElement {
    id res = [[[RxSingle
            just:@1]
            flatMap:^RxPrimitiveSequence *(NSNumber *element) {
                return [RxSingle just:@(element.integerValue * 2)];
            }]
            toBlocking].first;

    XCTAssertEqualObjects(res, @2);
}

- (void)testSingle_observeOn_producesSingleElement {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __auto_type res = [scheduler start:^RxObservable * {
        return [[[RxSingle just:@1] observeOn:scheduler] asObservable];
    }];

    __auto_type expected = @[next(201, @1), completed(202)];
    XCTAssertEqualObjects(res.events, expected);
}

- (void)testSingle_subscribeOn_producesSingleElement {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __auto_type res = [scheduler start:^RxObservable * {
        return [[[RxSingle just:@1] subscribeOn:scheduler] asObservable];
    }];

    __auto_type expected = @[next(201, @1), completed(201)];
    XCTAssertEqualObjects(res.events, expected);
}

- (void)testSingle_catchError_producesSingleElement {
    id res = [[[RxSingle
            error:testError()]
            catchError:^RxPrimitiveSequence *(NSError *error) {
                return [RxSingle just:@2];
            }]
            toBlocking].first;

    XCTAssertEqualObjects(res, @2);
}

- (void)testSingle_retry_producesSingleElement {
    __block BOOL isFirst = YES;

    id res = [[[[RxSingle
            error:testError()]
            catchError:^RxPrimitiveSequence *(NSError *error) {
                RxSingle *single = nil;
                if (isFirst) {
                    single = [RxSingle error:error];
                } else {
                    single = [RxSingle just:@2];
                }
                isFirst = NO;
                return single;
            }]
            retry:2]
            toBlocking].first;

    XCTAssertEqualObjects(res, @2);
}

- (void)testSingle_retryWhen_producesSingleElement {
    __block BOOL isFirst = YES;

    id res = [[[[RxSingle
            error:testError()]
            catchError:^RxPrimitiveSequence *(NSError *error) {
                RxSingle *single = nil;
                if (isFirst) {
                    single = [RxSingle error:error];
                } else {
                    single = [RxSingle just:@2];
                }
                isFirst = NO;
                return single;
            }]
            retryWhen:^id <RxObservableType>(RxObservable<__kindof NSError *> *observable) {
                return observable;
            }]
            toBlocking].first;

    XCTAssertEqualObjects(res, @2);
}

- (void)testSingle_timer_producesSingleElement {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [[RxSingle timer:2 scheduler:scheduler] asObservable];
    }];

    __auto_type expected = @[next(202, @0), completed(202)];

    XCTAssertEqualObjects(res.events, expected);
}

- (void)testAsSingle_subscribeOnSuccess {
    __auto_type events = [NSMutableArray array];

    id __unused _ = [[RxSingle just:@1] subscribeOnSuccess:^(id o) {
        [events addObject:o];
    } onError:^(NSError *error) {
        [events addObject:error];
    }];
    XCTAssertEqualObjects(events, @[@1]);
}

@end
