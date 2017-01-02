//
//  RxObservableSubscriptionTests.m
//  RxObjC
//
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"
#import "RxPublishSubject.h"
#import "RxTestError.h"

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCDFAInspection"

@interface RxObservableSubscriptionTests : RxTest

@end

@implementation RxObservableSubscriptionTests

- (void)testSubscribeOnNext {
    RxPublishSubject<NSNumber *> *publishSubject = [RxPublishSubject create];
    
    __block int onNextCalled = 0;
    __block int onErrorCalled = 0;
    __block int onCompletedCalled = 0;
    __block int onDisposedCalled = 0;
    
    __block NSNumber *lastElement = nil;
    __block NSError *lastError = nil;

    id <RxDisposable> subscription = [publishSubject subscribeOnNext:^(id o) {
        lastElement = o;
        onNextCalled++;
    } onError:^(NSError *error) {
        lastError = error;
        onErrorCalled++;
    } onCompleted:^{
        onCompletedCalled++;
    } onDisposed:^{
        onDisposedCalled++;
    }];

    XCTAssertTrue(lastElement == nil);
    XCTAssertTrue(lastError == nil);
    XCTAssertTrue(onNextCalled == 0);
    XCTAssertTrue(onErrorCalled == 0);
    XCTAssertTrue(onCompletedCalled == 0);
    XCTAssertTrue(onDisposedCalled == 0);

    rx_onNext(publishSubject, @1);

    XCTAssertTrue([lastElement isEqualToNumber:@1]);
    XCTAssertTrue(lastError == nil);
    XCTAssertTrue(onNextCalled == 1);
    XCTAssertTrue(onErrorCalled == 0);
    XCTAssertTrue(onCompletedCalled == 0);
    XCTAssertTrue(onDisposedCalled == 0);

    [subscription dispose];
    rx_onNext(publishSubject, @2);

    XCTAssertTrue([lastElement isEqualToNumber:@1]);
    XCTAssertTrue(lastError == nil);
    XCTAssertTrue(onNextCalled == 1);
    XCTAssertTrue(onErrorCalled == 0);
    XCTAssertTrue(onCompletedCalled == 0);
    XCTAssertTrue(onDisposedCalled == 1);
}

- (void)testSubscribeOnError {
    RxPublishSubject<NSNumber *> *publishSubject = [RxPublishSubject create];

    __block int onNextCalled = 0;
    __block int onErrorCalled = 0;
    __block int onCompletedCalled = 0;
    __block int onDisposedCalled = 0;

    __block NSNumber *lastElement = nil;
    __block NSError *lastError = nil;

    id <RxDisposable> subscription = [publishSubject subscribeOnNext:^(id o) {
        lastElement = o;
        onNextCalled++;
    } onError:^(NSError *error) {
        lastError = error;
        onErrorCalled++;
    } onCompleted:^{
        onCompletedCalled++;
    } onDisposed:^{
        onDisposedCalled++;
    }];

    XCTAssertTrue(lastElement == nil);
    XCTAssertTrue(lastError == nil);
    XCTAssertTrue(onNextCalled == 0);
    XCTAssertTrue(onErrorCalled == 0);
    XCTAssertTrue(onCompletedCalled == 0);
    XCTAssertTrue(onDisposedCalled == 0);

    rx_onError(publishSubject, [RxTestError testError]);

    XCTAssertTrue(lastElement == nil);
    XCTAssertTrue(lastError == [RxTestError testError]);
    XCTAssertTrue(onNextCalled == 0);
    XCTAssertTrue(onErrorCalled == 1);
    XCTAssertTrue(onCompletedCalled == 0);
    XCTAssertTrue(onDisposedCalled == 1);

    [subscription dispose];
    rx_onNext(publishSubject, @2);
    rx_onCompleted(publishSubject);

    XCTAssertTrue(lastElement == nil);
    XCTAssertTrue(lastError == [RxTestError testError]);
    XCTAssertTrue(onNextCalled == 0);
    XCTAssertTrue(onErrorCalled == 1);
    XCTAssertTrue(onCompletedCalled == 0);
    XCTAssertTrue(onDisposedCalled == 1);
}

- (void)testSubscribeOnCompleted {
    RxPublishSubject<NSNumber *> *publishSubject = [RxPublishSubject create];

    __block int onNextCalled = 0;
    __block int onErrorCalled = 0;
    __block int onCompletedCalled = 0;
    __block int onDisposedCalled = 0;

    __block NSNumber *lastElement = nil;
    __block NSError *lastError = nil;

    id <RxDisposable> subscription = [publishSubject subscribeOnNext:^(id o) {
        lastElement = o;
        onNextCalled++;
    } onError:^(NSError *error) {
        lastError = error;
        onErrorCalled++;
    } onCompleted:^{
        onCompletedCalled++;
    } onDisposed:^{
        onDisposedCalled++;
    }];

    XCTAssertTrue(lastElement == nil);
    XCTAssertTrue(lastError == nil);
    XCTAssertTrue(onNextCalled == 0);
    XCTAssertTrue(onErrorCalled == 0);
    XCTAssertTrue(onCompletedCalled == 0);
    XCTAssertTrue(onDisposedCalled == 0);

    rx_onCompleted(publishSubject);

    XCTAssertTrue(lastElement == nil);
    XCTAssertTrue(lastError == nil);
    XCTAssertTrue(onNextCalled == 0);
    XCTAssertTrue(onErrorCalled == 0);
    XCTAssertTrue(onCompletedCalled == 1);
    XCTAssertTrue(onDisposedCalled == 1);

    [subscription dispose];
    rx_onNext(publishSubject, @1);
    rx_onError(publishSubject, [RxTestError testError]);

    XCTAssertTrue(lastElement == nil);
    XCTAssertTrue(lastError == nil);
    XCTAssertTrue(onNextCalled == 0);
    XCTAssertTrue(onErrorCalled == 0);
    XCTAssertTrue(onCompletedCalled == 1);
    XCTAssertTrue(onDisposedCalled == 1);
}

- (void)testDisposed {
    RxPublishSubject<NSNumber *> *publishSubject = [RxPublishSubject create];

    __block int onNextCalled = 0;
    __block int onErrorCalled = 0;
    __block int onCompletedCalled = 0;
    __block int onDisposedCalled = 0;

    __block NSNumber *lastElement = nil;
    __block NSError *lastError = nil;

    id <RxDisposable> subscription = [publishSubject subscribeOnNext:^(id o) {
        lastElement = o;
        onNextCalled++;
    } onError:^(NSError *error) {
        lastError = error;
        onErrorCalled++;
    } onCompleted:^{
        onCompletedCalled++;
    } onDisposed:^{
        onDisposedCalled++;
    }];

    XCTAssertTrue(lastElement == nil);
    XCTAssertTrue(lastError == nil);
    XCTAssertTrue(onNextCalled == 0);
    XCTAssertTrue(onErrorCalled == 0);
    XCTAssertTrue(onCompletedCalled == 0);
    XCTAssertTrue(onDisposedCalled == 0);

    rx_onNext(publishSubject, @1);
    [subscription dispose];
    rx_onNext(publishSubject, @2);
    rx_onError(publishSubject, [RxTestError testError]);
    rx_onCompleted(publishSubject);

    XCTAssertTrue([lastElement isEqualToNumber:@1]);
    XCTAssertTrue(lastError == nil);
    XCTAssertTrue(onNextCalled == 1);
    XCTAssertTrue(onErrorCalled == 0);
    XCTAssertTrue(onCompletedCalled == 0);
    XCTAssertTrue(onDisposedCalled == 1);
}

@end

#pragma clang diagnostic pop