//
//  RxObservableBindingTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RxObservable+RxBinding.h"
#import "RxTest.h"
#import "RxTestScheduler.h"
#import "XCTest+Rx.h"
#import "RxTestableObservable.h"
#import "RxPublishSubject.h"
#import "RxTestableObserver.h"
#import "RxSubscription.h"
#import "RxTestError.h"
#import "RxObservable+RxZip.h"

@interface RxObservableBindingTest : RxTest

@end

@implementation RxObservableBindingTest

- (void)testMulticast_Cold_Completed {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable<NSNumber *> *xs = [scheduler createHotObservable:@[
            [self next:40 element:@0],
            [self next:90 element:@1],
            [self next:150 element:@2],
            [self next:210 element:@3],
            [self next:240 element:@4],
            [self next:270 element:@5],
            [self next:330 element:@6],
            [self next:340 element:@7],
            [self completed:390]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs multicast:^id <RxSubjectType> {
            return [RxPublishSubject create];
        } selector:^RxObservable *(RxObservable *observable) {
            return observable;
        }];
    }];

    NSArray<RxRecorded <RxEvent<NSNumber *> *> *> *array = @[
            [self next:210 element:@3],
            [self next:240 element:@4],
            [self next:270 element:@5],
            [self next:330 element:@6],
            [self next:340 element:@7],
            [self completed:390]
    ];
    XCTAssertTrue([res.events isEqualToArray:array]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:200 unsubscribe:390]]]);
}

- (void)testMulticast_Cold_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable<NSNumber *> *xs = [scheduler createHotObservable:@[
            [self next:40 element:@0],
            [self next:90 element:@1],
            [self next:150 element:@2],
            [self next:210 element:@3],
            [self next:240 element:@4],
            [self next:270 element:@5],
            [self next:330 element:@6],
            [self next:340 element:@7],
            [self error:390 testError:[RxTestError testError]]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs multicast:^id <RxSubjectType> {
            return [RxPublishSubject create];
        } selector:^RxObservable *(RxObservable *observable) {
            return observable;
        }];
    }];

    NSArray<RxRecorded <RxEvent<NSNumber *> *> *> *array = @[
            [self next:210 element:@3],
            [self next:240 element:@4],
            [self next:270 element:@5],
            [self next:330 element:@6],
            [self next:340 element:@7],
            [self error:390 testError:[RxTestError testError]]
    ];
    XCTAssertTrue([res.events isEqualToArray:array]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:200 unsubscribe:390]]]);
}

- (void)testMulticast_Cold_Dispose {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable<NSNumber *> *xs = [scheduler createHotObservable:@[
            [self next:40 element:@0],
            [self next:90 element:@1],
            [self next:150 element:@2],
            [self next:210 element:@3],
            [self next:240 element:@4],
            [self next:270 element:@5],
            [self next:330 element:@6],
            [self next:340 element:@7],
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs multicast:^id <RxSubjectType> {
            return [RxPublishSubject create];
        } selector:^RxObservable *(RxObservable *observable) {
            return observable;
        }];
    }];

    NSArray<RxRecorded <RxEvent<NSNumber *> *> *> *array = @[
            [self next:210 element:@3],
            [self next:240 element:@4],
            [self next:270 element:@5],
            [self next:330 element:@6],
            [self next:340 element:@7],
    ];
    XCTAssertTrue([res.events isEqualToArray:array]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:200 unsubscribe:1000]]]);
}

- (void)testMulticast_Cold_Zip {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable<NSNumber *> *xs = [scheduler createHotObservable:@[
            [self next:40 element:@0],
            [self next:90 element:@1],
            [self next:150 element:@2],
            [self next:210 element:@3],
            [self next:240 element:@4],
            [self next:270 element:@5],
            [self next:330 element:@6],
            [self next:340 element:@7],
            [self completed:390]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs multicast:^id <RxSubjectType> {
            return [RxPublishSubject create];
        } selector:^RxObservable *(RxObservable *observable) {
            return [RxObservable zip:observable and:observable resultSelector:^NSNumber *(NSNumber *a, NSNumber *b) {
                return @(a.intValue + b.intValue);
            }];
        }];
    }];

    NSArray<RxRecorded <RxEvent<NSNumber *> *> *> *array = @[
            [self next:210 element:@6],
            [self next:240 element:@8],
            [self next:270 element:@10],
            [self next:330 element:@12],
            [self next:340 element:@14],
            [self completed:390]
    ];
    XCTAssertTrue([res.events isEqualToArray:array]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:200 unsubscribe:390]]]);
}

- (void)testMulticast_SubjectSelectorThrowsError {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:210 element:@1],
            [self next:240 element:@2],
            [self completed:300]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs multicast:^id <RxSubjectType> {
            @throw [RxTestError testError];
            return [RxPublishSubject create];
        } selector:^RxObservable *(RxObservable *observable) {
            return observable;
        }];
    }];

    XCTAssertTrue([res.events isEqualToArray:@[[self error:200 testError:[RxTestError testError]]]], @"");

    XCTAssertTrue(xs.subscriptions.count == 0);
}

- (void)testMulticast_SubjectSelectorThrowsException {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:210 element:@1],
            [self next:240 element:@2],
            [self completed:300]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs multicast:^id <RxSubjectType> {
            id error = [[NSObject alloc] init];
            [error objectAtIndex:0];
            return [RxPublishSubject create];
        } selector:^RxObservable *(RxObservable *observable) {
            return observable;
        }];
    }];

    XCTAssertTrue(res.events.count == 1);
    RxRecorded<RxEvent *> *type = res.events[0];
    XCTAssertTrue(type.value.error.code == 105);
    XCTAssertTrue(xs.subscriptions.count == 0);
}

@end
