//
//  RxObservableSubscriptionTests.m
//  RxObjC
//
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RxTest.h"
#import "RxPublishSubject.h"

@interface RxObservableSubscriptionTests : RxTest

@end

@implementation RxObservableSubscriptionTests

// TODO закончить!
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

    [publishSubject onNext:@1];

    XCTAssertTrue([lastElement isEqualToNumber:@1]);
    XCTAssertTrue(lastError == nil);
    XCTAssertTrue(onNextCalled == 1);
    XCTAssertTrue(onErrorCalled == 0);
    XCTAssertTrue(onCompletedCalled == 0);
    XCTAssertTrue(onDisposedCalled == 0);

    [subscription dispose];
    [publishSubject onNext:@2];

    XCTAssertTrue([lastElement isEqualToNumber:@1]);
    XCTAssertTrue(lastError == nil);
    XCTAssertTrue(onNextCalled == 1);
    XCTAssertTrue(onErrorCalled == 0);
    XCTAssertTrue(onCompletedCalled == 0);
    XCTAssertTrue(onDisposedCalled == 1);
}

@end
