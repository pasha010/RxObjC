//
//  RxAnonymousObservable+Test.m
//  RxObjC
//
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"
#import "RxAnyObserver.h"
#import "RxObservable+Creation.h"
#import "RxNopDisposable.h"
#import "RxTestError.h"

@interface RxAnonymousObservableTests : RxTest

@end

@implementation RxAnonymousObservableTests

- (void)testAnonymousObservable_detachesOnDispose {
    __block RxAnyObserver<NSNumber *> *observer;
    RxObservable<NSNumber *> *a = [RxObservable create:^id <RxDisposable>(RxAnyObserver *o) {
        observer = o;
        return [RxNopDisposable sharedInstance];
    }];

    NSMutableArray<NSNumber *> *elements = [NSMutableArray array];

    id <RxDisposable> d = [a subscribeNext:^(NSNumber *n) {
        [elements addObject:n];
    }];

    XCTAssertTrue([elements isEqualToArray:@[]]);

    [observer onNext:@0];

    XCTAssertTrue([elements isEqualToArray:@[@0]]);

    [d dispose];

    [observer onNext:@1];

    XCTAssertTrue([elements isEqualToArray:@[@0]]);
}

- (void)testAnonymousObservable_detachesOnComplete {
    __block RxAnyObserver<NSNumber *> *observer;
    RxObservable<NSNumber *> *a = [RxObservable create:^id <RxDisposable>(RxAnyObserver *o) {
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

- (void)testAnonymousObservable_detachesOnError {
    __block RxAnyObserver<NSNumber *> *observer;
    RxObservable<NSNumber *> *a = [RxObservable create:^id <RxDisposable>(RxAnyObserver *o) {
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

    [observer onError:[RxTestError testError]];

    [observer onNext:@1];

    XCTAssertTrue([elements isEqualToArray:@[@0]]);
}

@end
