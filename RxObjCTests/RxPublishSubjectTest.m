//
//  RxPublishSubjectTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 21.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RxTest.h"
#import "RxTestScheduler.h"
#import "RxPublishSubject.h"
#import "RxTestableObserver.h"

@interface RxPublishSubjectTest : RxTest

@end

@implementation RxPublishSubjectTest

- (void)test_hasObserversNoObservers {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block RxPublishSubject<NSNumber *> *subject = nil;

    [scheduler scheduleAt:100 action:^{
        subject = [RxPublishSubject create];
    }];

    [scheduler scheduleAt:250 action:^{
        XCTAssertFalse(subject.hasObservers);
    }];

    [scheduler start];
}

- (void)test_hasObserversOneObserver {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block RxPublishSubject<NSNumber *> *subject = nil;

    RxTestableObserver<NSNumber *> *results1 = [scheduler createObserver];
    __block id <RxDisposable> subscription1 = nil;

    [scheduler scheduleAt:100 action:^{
        subject = [RxPublishSubject create];
    }];

    [scheduler scheduleAt:250 action:^{
        XCTAssertFalse(subject.hasObservers);
    }];

    [scheduler scheduleAt:300 action:^{
        subscription1 = [subject subscribe:results1];
    }];

    [scheduler scheduleAt:350 action:^{
        XCTAssertTrue(subject.hasObservers);
    }];

    [scheduler scheduleAt:400 action:^{
        [subscription1 dispose];
    }];

    [scheduler scheduleAt:450 action:^{
        XCTAssertFalse(subject.hasObservers);
    }];

    [scheduler start];
}

- (void)test_hasObserversManyObserver {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block RxPublishSubject<NSNumber *> *subject = nil;

    RxTestableObserver<NSNumber *> *results1 = [scheduler createObserver];
    __block id <RxDisposable> subscription1 = nil;

    RxTestableObserver<NSNumber *> *results2 = [scheduler createObserver];
    __block id <RxDisposable> subscription2 = nil;

    RxTestableObserver<NSNumber *> *results3 = [scheduler createObserver];
    __block id <RxDisposable> subscription3 = nil;

    [scheduler scheduleAt:100 action:^{
        subject = [RxPublishSubject create];
    }];

    [scheduler scheduleAt:250 action:^{
        XCTAssertFalse(subject.hasObservers);
    }];

    [scheduler scheduleAt:300 action:^{
        subscription1 = [subject subscribe:results1];
    }];

    [scheduler scheduleAt:301 action:^{
        subscription2 = [subject subscribe:results2];
    }];

    [scheduler scheduleAt:302 action:^{
        subscription3 = [subject subscribe:results3];
    }];

    [scheduler scheduleAt:350 action:^{
        XCTAssertTrue(subject.hasObservers);
    }];

    [scheduler scheduleAt:400 action:^{
        [subscription1 dispose];
    }];

    [scheduler scheduleAt:405 action:^{
        XCTAssertTrue(subject.hasObservers);
    }];

    [scheduler scheduleAt:410 action:^{
        [subscription2 dispose];
    }];

    [scheduler scheduleAt:415 action:^{
        XCTAssertTrue(subject.hasObservers);
    }];

    [scheduler scheduleAt:420 action:^{
        [subscription3 dispose];
    }];

    [scheduler scheduleAt:450 action:^{
        XCTAssertFalse(subject.hasObservers);
    }];

    [scheduler start];
}

@end
