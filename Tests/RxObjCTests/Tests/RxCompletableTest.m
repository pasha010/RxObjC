//
//  RxMaybeTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 01.09.17.
//  Copyright © 2017 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RxTest.h"

@interface RxCompletableTest : RxTest
@end

@implementation RxCompletableTest

- (void)testAsCompletable_Empty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __auto_type xs = [scheduler createHotObservable:@[
            completed(250),
            error(260, testError()),
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        RxCompletable *completable = [[xs asObservable] asCompletable];
        return [completable asObservable];
    }];

    XCTAssertEqualObjects(res.events, @[completed(250)]);
    XCTAssertEqualObjects(xs.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:250]]);
}

- (void)testAsCompletable_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __auto_type xs = [scheduler createHotObservable:@[
            error(210, testError()),
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        RxCompletable *completable = [[xs asObservable] asCompletable];
        return [completable asObservable];
    }];

    __auto_type expected = @[error(210, testError())];
    XCTAssertEqualObjects(res.events, expected);
    XCTAssertEqualObjects(xs.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:210]]);
}

- (void)testAsCompletable_subscribeOnCompleted {
    __block BOOL isCompleted = NO;
    __block BOOL isError = NO;

    id _ = [[RxCompletable empty] subscribeOnCompleted:^{
        isCompleted = YES;
    } onError:^(NSError *error) {
        isError = YES;
    }];

    XCTAssertTrue(isCompleted);
    XCTAssertTrue(isError);
}

- (void)testAsCompletable_subscribeOnError {
    __block BOOL isCompleted = NO;
    __block BOOL isError = NO;

    id _ = [[RxCompletable error:testError()] subscribeOnCompleted:^{
        isCompleted = YES;
    } onError:^(NSError *error) {
        isError = YES;
    }];

    XCTAssertTrue(isCompleted);
    XCTAssertTrue(isError);
}

- (void)testCompletable_merge {
    /*__auto_type factories = @[
            ^(RxCompletable *ys1, RxCompletable *ys2) {
                return [RxCompletable merge:@[ys1, ys2]];
            },
            ^(RxCompletable *ys1, RxCompletable *ys2) {
                return [RxCompletable merge:@[ys1, ys2]];
            },
            ^(RxCompletable *ys1, RxCompletable *ys2) {
                return [RxCompletable merge:@[ys1, ys2]];
            },
    ];

    [factories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
        RxTestableObservable *ys1 = [scheduler createHotObservable:@[completed(250), error(260, testError())]];
        RxTestableObservable *ys2 = [scheduler createHotObservable:@[completed(300)]];

    }];*/
    
    /**
     * let factories: [(Completable, Completable) -> Completable] =
            [
                { ys1, ys2 in Completable.merge(ys1, ys2) },
                { ys1, ys2 in Completable.merge([ys1, ys2]) },
                { ys1, ys2 in Completable.merge(AnyCollection([ys1, ys2])) },
                ]
        
        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)
            
            let ys1 = scheduler.createHotObservable([
                completed(250, Never.self),
                error(260, testError)
                ])
            
            let ys2 = scheduler.createHotObservable([
                completed(300, Never.self)
                ])
            
            let res = scheduler.start { () -> Observable<Never> in
                let completable: Completable = factory(ys1.asCompletable(), ys2.asCompletable())
                return completable.asObservable()
            }
            
            XCTAssertEqual(res.events, [
                completed(300)
                ])
            
            XCTAssertEqual(ys1.subscriptions, [
                Subscription(200, 250),
                ])
            
            XCTAssertEqual(ys2.subscriptions, [
                Subscription(200, 300),
                ])
        }
     */
}

@end
