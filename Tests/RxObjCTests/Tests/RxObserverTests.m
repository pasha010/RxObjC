//
//  RxObserverTests.m
//  RxObjC
//
//  Created by Pavel Malkov on 10.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"
#import "RxAnyObserver.h"
#import "RxObservable+Creation.h"
#import "RxNopDisposable.h"
#import "RxTestError.h"

@interface RxObserverTests : RxTest

@end

@implementation RxObserverTests

- (void)testConvenienceOn_Next {
    __block RxAnyObserver<NSNumber *> *observer = nil;

    RxObservable<NSNumber *> *a = [RxObservable create:^id <RxDisposable>(RxAnyObserver<NSNumber *> *o) {
        observer = o;
        return [RxNopDisposable sharedInstance];
    }];

    NSMutableArray<NSNumber *> *elements = [NSMutableArray array];

    [a subscribeNext:^(NSNumber *n) {
        [elements addObject:n];
    }];

    XCTAssertTrue([elements isEqualToArray:@[]]);

    [observer onNext:@0];

    XCTAssertTrue([elements isEqualToArray:@[@0]]);
}

- (void)testConvenienceOn_Error {
    __block RxAnyObserver<NSNumber *> *observer = nil;

    RxObservable<NSNumber *> *a = [RxObservable create:^id <RxDisposable>(RxAnyObserver<NSNumber *> *o) {
        observer = o;
        return [RxNopDisposable sharedInstance];
    }];

    NSMutableArray<NSNumber *> *elements = [NSMutableArray array];
    __block NSError *errorNotification = nil;

    [a subscribeOnNext:^(NSNumber *n) {
        [elements addObject:n];
    } onError:^(NSError *error) {
       errorNotification = error;
    }];

    XCTAssertTrue([elements isEqualToArray:@[]]);

    [observer onNext:@0];
    XCTAssertTrue([elements isEqualToArray:@[@0]]);

    [observer onError:[RxTestError testError]];

    [observer onNext:@1];
    XCTAssertTrue([elements isEqualToArray:@[@0]]);
    XCTAssertTrue([errorNotification isEqual:[RxTestError testError]]);
}

- (void)testConvenienceOn_Complete {
    __block RxAnyObserver<NSNumber *> *observer = nil;

    RxObservable<NSNumber *> *a = [RxObservable create:^id <RxDisposable>(RxAnyObserver<NSNumber *> *o) {
        observer = o;
        return [RxNopDisposable sharedInstance];
    }];

    NSMutableArray<NSNumber *> *elements = [NSMutableArray array];

    [a subscribeNext:^(NSNumber *n) {
        [elements addObject:n];
    }];

    XCTAssertTrue([elements isEqualToArray:@[]]);

    [observer onNext:@0];
    XCTAssertTrue([elements isEqualToArray:@[@0]]);

    [observer onCompleted];

    [observer onNext:@1];
    XCTAssertTrue([elements isEqualToArray:@[@0]]);
}

@end
