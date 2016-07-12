//
//  RxBehaviorSubjectTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"
#import "RxTestableObservable.h"
#import "RxTestableObserver.h"
#import "RxTestScheduler.h"
#import "XCTest+Rx.h"
#import "RxBehaviorSubject.h"
#import "RxTestError.h"

@interface RxBehaviorSubjectTest : RxTest

@end

@implementation RxBehaviorSubjectTest

- (void)test_Infinite {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:70 element:@1],
            [self next:110 element:@2],
            [self next:220 element:@3],
            [self next:270 element:@4],
            [self next:340 element:@5],
            [self next:410 element:@6],
            [self next:520 element:@7],
            [self next:630 element:@8],
            [self next:710 element:@9],
            [self next:870 element:@10],
            [self next:940 element:@11],
            [self next:1020 element:@12],
    ]];
    
    __block RxBehaviorSubject<NSNumber *> *subject;
    __block id <RxDisposable> subscription = nil;

    __block RxTestableObserver *results1 = [scheduler createObserver];
    __block id <RxDisposable> subscription1 = nil;

    __block RxTestableObserver *results2 = [scheduler createObserver];
    __block id <RxDisposable> subscription2 = nil;

    __block RxTestableObserver *results3 = [scheduler createObserver];
    __block id <RxDisposable> subscription3 = nil;

    [scheduler scheduleAt:100 action:^{ subject = [RxBehaviorSubject create:@100]; }];
    [scheduler scheduleAt:200 action:^{ subscription = [xs subscribe:subject]; }];
    [scheduler scheduleAt:1000 action:^{ [subscription dispose]; }];

    [scheduler scheduleAt:300 action:^{ subscription1 = [subject subscribe:results1]; }];
    [scheduler scheduleAt:400 action:^{ subscription2 = [subject subscribe:results2]; }];
    [scheduler scheduleAt:900 action:^{ subscription3 = [subject subscribe:results3]; }];
    
    [scheduler scheduleAt:600 action:^{ [subscription1 dispose]; }];
    [scheduler scheduleAt:700 action:^{ [subscription2 dispose]; }];
    [scheduler scheduleAt:800 action:^{ [subscription1 dispose]; }];
    [scheduler scheduleAt:950 action:^{ [subscription3 dispose]; }];

    [scheduler start];

    NSArray *array = @[
            [self next:300 element:@4],
            [self next:340 element:@5],
            [self next:410 element:@6],
            [self next:520 element:@7],
    ];
    
    XCTAssertTrue([results1.events isEqualToArray:array]);

    NSArray *array1 = @[
            [self next:400 element:@5],
            [self next:410 element:@6],
            [self next:520 element:@7],
            [self next:630 element:@8],
    ];
    XCTAssertTrue([results2.events isEqualToArray:array1]);

    NSArray *array2 = @[
            [self next:900 element:@10],
            [self next:940 element:@11],
    ];

    XCTAssertTrue([results3.events isEqualToArray:array2]);
}

- (void)test_Finite {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:70 element:@1],
            [self next:110 element:@2],
            [self next:220 element:@3],
            [self next:270 element:@4],
            [self next:340 element:@5],
            [self next:410 element:@6],
            [self next:520 element:@7],
            [self completed:630],
            [self next:640 element:@9],
            [self completed:650],
            [self error:660 testError:[RxTestError testError]]
    ]];

    __block RxBehaviorSubject<NSNumber *> *subject;
    __block id <RxDisposable> subscription = nil;

    __block RxTestableObserver *results1 = [scheduler createObserver];
    __block id <RxDisposable> subscription1 = nil;

    __block RxTestableObserver *results2 = [scheduler createObserver];
    __block id <RxDisposable> subscription2 = nil;

    __block RxTestableObserver *results3 = [scheduler createObserver];
    __block id <RxDisposable> subscription3 = nil;

    [scheduler scheduleAt:100 action:^{ subject = [RxBehaviorSubject create:@100]; }];
    [scheduler scheduleAt:200 action:^{ subscription = [xs subscribe:subject]; }];
    [scheduler scheduleAt:1000 action:^{ [subscription dispose]; }];

    [scheduler scheduleAt:300 action:^{ subscription1 = [subject subscribe:results1]; }];
    [scheduler scheduleAt:400 action:^{ subscription2 = [subject subscribe:results2]; }];
    [scheduler scheduleAt:900 action:^{ subscription3 = [subject subscribe:results3]; }];

    [scheduler scheduleAt:600 action:^{ [subscription1 dispose]; }];
    [scheduler scheduleAt:700 action:^{ [subscription2 dispose]; }];
    [scheduler scheduleAt:800 action:^{ [subscription1 dispose]; }];
    [scheduler scheduleAt:950 action:^{ [subscription3 dispose]; }];

    [scheduler start];

    NSArray *array = @[
            [self next:300 element:@4],
            [self next:340 element:@5],
            [self next:410 element:@6],
            [self next:520 element:@7],
    ];

    XCTAssertTrue([results1.events isEqualToArray:array]);

    NSArray *array1 = @[
            [self next:400 element:@5],
            [self next:410 element:@6],
            [self next:520 element:@7],
            [self completed:630]
    ];
    XCTAssertTrue([results2.events isEqualToArray:array1]);

    NSArray *array2 = @[
            [self completed:900]
    ];

    XCTAssertTrue([results3.events isEqualToArray:array2]);
}

- (void)test_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:70 element:@1],
            [self next:110 element:@2],
            [self next:220 element:@3],
            [self next:270 element:@4],
            [self next:340 element:@5],
            [self next:410 element:@6],
            [self next:520 element:@7],
            [self error:630 testError:[RxTestError testError]],
            [self next:640 element:@9],
            [self completed:650],
            [self error:660 testError:[RxTestError testError]]
    ]];

    __block RxBehaviorSubject<NSNumber *> *subject;
    __block id <RxDisposable> subscription = nil;

    __block RxTestableObserver *results1 = [scheduler createObserver];
    __block id <RxDisposable> subscription1 = nil;

    __block RxTestableObserver *results2 = [scheduler createObserver];
    __block id <RxDisposable> subscription2 = nil;

    __block RxTestableObserver *results3 = [scheduler createObserver];
    __block id <RxDisposable> subscription3 = nil;

    [scheduler scheduleAt:100 action:^{ subject = [RxBehaviorSubject create:@100]; }];
    [scheduler scheduleAt:200 action:^{ subscription = [xs subscribe:subject]; }];
    [scheduler scheduleAt:1000 action:^{ [subscription dispose]; }];

    [scheduler scheduleAt:300 action:^{ subscription1 = [subject subscribe:results1]; }];
    [scheduler scheduleAt:400 action:^{ subscription2 = [subject subscribe:results2]; }];
    [scheduler scheduleAt:900 action:^{ subscription3 = [subject subscribe:results3]; }];

    [scheduler scheduleAt:600 action:^{ [subscription1 dispose]; }];
    [scheduler scheduleAt:700 action:^{ [subscription2 dispose]; }];
    [scheduler scheduleAt:800 action:^{ [subscription1 dispose]; }];
    [scheduler scheduleAt:950 action:^{ [subscription3 dispose]; }];

    [scheduler start];

    NSArray *array = @[
            [self next:300 element:@4],
            [self next:340 element:@5],
            [self next:410 element:@6],
            [self next:520 element:@7],
    ];

    XCTAssertTrue([results1.events isEqualToArray:array]);

    NSArray *array1 = @[
            [self next:400 element:@5],
            [self next:410 element:@6],
            [self next:520 element:@7],
            [self error:630 testError:[RxTestError testError]]
    ];
    XCTAssertTrue([results2.events isEqualToArray:array1]);

    NSArray *array2 = @[
            [self error:900 testError:[RxTestError testError]]
    ];

    XCTAssertTrue([results3.events isEqualToArray:array2]);
}

- (void)test_Canceled {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self completed:630],
            [self next:640 element:@9],
            [self completed:650],
            [self error:660 testError:[RxTestError testError]]
    ]];

    __block RxBehaviorSubject<NSNumber *> *subject;
    __block id <RxDisposable> subscription = nil;

    __block RxTestableObserver *results1 = [scheduler createObserver];
    __block id <RxDisposable> subscription1 = nil;

    __block RxTestableObserver *results2 = [scheduler createObserver];
    __block id <RxDisposable> subscription2 = nil;

    __block RxTestableObserver *results3 = [scheduler createObserver];
    __block id <RxDisposable> subscription3 = nil;

    [scheduler scheduleAt:100 action:^{ subject = [RxBehaviorSubject create:@100]; }];
    [scheduler scheduleAt:200 action:^{ subscription = [xs subscribe:subject]; }];
    [scheduler scheduleAt:1000 action:^{ [subscription dispose]; }];

    [scheduler scheduleAt:300 action:^{ subscription1 = [subject subscribe:results1]; }];
    [scheduler scheduleAt:400 action:^{ subscription2 = [subject subscribe:results2]; }];
    [scheduler scheduleAt:900 action:^{ subscription3 = [subject subscribe:results3]; }];

    [scheduler scheduleAt:600 action:^{ [subscription1 dispose]; }];
    [scheduler scheduleAt:700 action:^{ [subscription2 dispose]; }];
    [scheduler scheduleAt:800 action:^{ [subscription1 dispose]; }];
    [scheduler scheduleAt:950 action:^{ [subscription3 dispose]; }];

    [scheduler start];

    NSArray *array = @[
            [self next:300 element:@100]
    ];

    XCTAssertTrue([results1.events isEqualToArray:array]);

    NSArray *array1 = @[
            [self next:400 element:@100],
            [self completed:630]
    ];
    XCTAssertTrue([results2.events isEqualToArray:array1]);

    NSArray *array2 = @[
            [self completed:900]
    ];

    XCTAssertTrue([results3.events isEqualToArray:array2]);
}

- (void)test_hasObserversNoObservers {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    
    __block RxBehaviorSubject<NSNumber *> *subject = nil;

    [scheduler scheduleAt:100 action:^{ subject = [RxBehaviorSubject create:@100]; }];
    [scheduler scheduleAt:250 action:^{ XCTAssertFalse(subject.hasObservers); }];

    [scheduler start];
}

- (void)test_hasObserversOneObserver {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block RxBehaviorSubject<NSNumber *> *subject = nil;

    __block RxTestableObserver<NSNumber *> *results1 = [scheduler createObserver];
    __block id <RxDisposable> subscription1 = nil;

    [scheduler scheduleAt:100 action:^{ subject = [RxBehaviorSubject create:@100]; }];
    [scheduler scheduleAt:250 action:^{ XCTAssertFalse(subject.hasObservers); }];
    [scheduler scheduleAt:300 action:^{ subscription1 = [subject subscribe:results1]; }];
    [scheduler scheduleAt:350 action:^{ XCTAssertTrue(subject.hasObservers); }];
    [scheduler scheduleAt:400 action:^{ [subscription1 dispose]; }];
    [scheduler scheduleAt:450 action:^{ XCTAssertFalse(subject.hasObservers); }];

    [scheduler start];
}

- (void)test_hasObserversManyObserver {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block RxBehaviorSubject<NSNumber *> *subject = nil;

    __block RxTestableObserver<NSNumber *> *results1 = [scheduler createObserver];
    __block id <RxDisposable> subscription1 = nil;

    __block RxTestableObserver<NSNumber *> *results2 = [scheduler createObserver];
    __block id <RxDisposable> subscription2 = nil;

    __block RxTestableObserver<NSNumber *> *results3 = [scheduler createObserver];
    __block id <RxDisposable> subscription3 = nil;

    [scheduler scheduleAt:100 action:^{ subject = [RxBehaviorSubject create:@100]; }];
    [scheduler scheduleAt:250 action:^{ XCTAssertFalse(subject.hasObservers); }];
    [scheduler scheduleAt:300 action:^{ subscription1 = [subject subscribe:results1]; }];
    [scheduler scheduleAt:301 action:^{ subscription2 = [subject subscribe:results2]; }];
    [scheduler scheduleAt:302 action:^{ subscription3 = [subject subscribe:results3]; }];
    [scheduler scheduleAt:350 action:^{ XCTAssertTrue(subject.hasObservers); }];
    [scheduler scheduleAt:400 action:^{ [subscription1 dispose]; }];
    [scheduler scheduleAt:405 action:^{ XCTAssertTrue(subject.hasObservers); }];
    [scheduler scheduleAt:410 action:^{ [subscription2 dispose]; }];
    [scheduler scheduleAt:415 action:^{ XCTAssertTrue(subject.hasObservers); }];
    [scheduler scheduleAt:420 action:^{ [subscription3 dispose]; }];
    [scheduler scheduleAt:450 action:^{ XCTAssertFalse(subject.hasObservers); }];

    [scheduler start];
}

@end
