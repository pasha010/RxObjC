//
//  RxDisposableTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 10.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"
#import "RxDisposable.h"
#import "RxAnonymousDisposable.h"
#import "XCTest+Rx.h"
#import "RxSubscription.h"
#import "RxCompositeDisposable.h"
#import "RxBooleanDisposable.h"
#import "RxRefCountDisposable.h"

@interface RxDisposableTest : RxTest

@end

@implementation RxDisposableTest

- (void)testActionDisposable {
    __block NSUInteger counter = 0;
    RxAnonymousDisposable *disposable = [[RxAnonymousDisposable alloc] initWithDisposeAction:^{
        counter++;
    }];
    
    XCTAssert(counter == 0);
    [disposable dispose];
    XCTAssert(counter == 1);
    [disposable dispose];
    XCTAssert(counter == 1);
}

- (void)testHotObservable_Disposing {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:110 element:@1],
            [self next:180 element:@2],
            [self next:230 element:@3],
            [self next:270 element:@4],
            [self next:340 element:@5],
            [self next:380 element:@6],
            [self next:390 element:@7],
            [self next:450 element:@8],
            [self next:470 element:@9],
            [self next:560 element:@10],
            [self next:580 element:@11],
            [self completed:600]
    ]];

    RxTestableObserver *res = [scheduler start:400 create:^RxObservable * {
        return [xs asObservable];
    }];

    NSArray *array = @[
            [self next:230 element:@3],
            [self next:270 element:@4],
            [self next:340 element:@5],
            [self next:380 element:@6],
            [self next:390 element:@7],
    ];
    XCTAssertTrue([res.events isEqualToArray:array]);
    
    XCTAssertTrue([xs.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:200 unsubscribe:400]]]);
}

- (void)testCompositeDisposable_TestNormal {
    __block NSUInteger numberDisposed = 0;

    RxCompositeDisposable *compositeDisposable = [[RxCompositeDisposable alloc] init];

    RxBagKey *result1 = [compositeDisposable addDisposable:[[RxAnonymousDisposable alloc] initWithDisposeAction:^{
        numberDisposed++;
    }]];

    [compositeDisposable addDisposable:[[RxAnonymousDisposable alloc] initWithDisposeAction:^{
        numberDisposed++;
    }]];
    
    XCTAssertTrue(numberDisposed == 0);
    XCTAssertTrue(compositeDisposable.count == 2);
    XCTAssertTrue(result1 != nil);

    [compositeDisposable dispose];
    XCTAssertTrue(numberDisposed == 2);
    XCTAssertTrue(compositeDisposable.count == 0);

    RxBagKey *result = [compositeDisposable addDisposable:[[RxAnonymousDisposable alloc] initWithDisposeAction:^{
        numberDisposed++;
    }]];

    XCTAssertTrue(numberDisposed == 3);
    XCTAssertTrue(compositeDisposable.count == 0);

    XCTAssertTrue(result == nil);
}

- (void)testCompositeDisposable_TestInitWithNumberOfDisposables {
    __block NSUInteger numberDisposed = 0;

    RxAnonymousDisposable *disposable1 = [[RxAnonymousDisposable alloc] initWithDisposeAction:^{
        numberDisposed++;
    }];
    
    RxAnonymousDisposable *disposable2 = [[RxAnonymousDisposable alloc] initWithDisposeAction:^{
        numberDisposed++;
    }];
    
    RxAnonymousDisposable *disposable3 = [[RxAnonymousDisposable alloc] initWithDisposeAction:^{
        numberDisposed++;
    }];
    
    RxAnonymousDisposable *disposable4 = [[RxAnonymousDisposable alloc] initWithDisposeAction:^{
        numberDisposed++;
    }];
    
    RxAnonymousDisposable *disposable5 = [[RxAnonymousDisposable alloc] initWithDisposeAction:^{
        numberDisposed++;
    }];

    RxCompositeDisposable *compositeDisposable = [[RxCompositeDisposable alloc] initWithDisposableArray:@[disposable1, disposable2, disposable3, disposable4, disposable5]];
    
    XCTAssertTrue(numberDisposed == 0);
    XCTAssertTrue(compositeDisposable.count == 5);

    [compositeDisposable dispose];
    
    XCTAssertTrue(numberDisposed == 5);
    XCTAssertTrue(compositeDisposable.count == 0);
    
}

- (void)testCompositeDisposable_TestRemoving {
    __block NSUInteger numberDisposed = 0;

    RxCompositeDisposable *compositeDisposable = [[RxCompositeDisposable alloc] init];

    RxBagKey *result1 = [compositeDisposable addDisposable:[[RxAnonymousDisposable alloc] initWithDisposeAction:^{
        numberDisposed++;
    }]];

    RxBagKey *result2 = [compositeDisposable addDisposable:[[RxAnonymousDisposable alloc] initWithDisposeAction:^{
        numberDisposed++;
    }]];

    XCTAssertTrue(numberDisposed == 0);
    XCTAssertTrue(compositeDisposable.count == 2);
    XCTAssertTrue(result1 != nil);

    [compositeDisposable removeDisposable:result2];
    XCTAssertTrue(numberDisposed == 1);
    XCTAssertTrue(compositeDisposable.count == 1);
    
    [compositeDisposable dispose];

    XCTAssertTrue(numberDisposed == 2);
    XCTAssertTrue(compositeDisposable.count == 0);
}

- (void)testRefCountDisposable_RefCounting {
    RxBooleanDisposable *d = [[RxBooleanDisposable alloc] init];
    RxRefCountDisposable *r = [[RxRefCountDisposable alloc] initWithDisposable:d];
    
    XCTAssertTrue(r.disposed == NO);

    id <RxDisposable> d1 = [r rx_retain];
    id <RxDisposable> d2 = [r rx_retain];
    
    XCTAssertTrue(d.disposed == NO);

    [d1 dispose];
    XCTAssertTrue(d.disposed == NO);

    [d2 dispose];
    XCTAssertTrue(d.disposed == NO);

    [r dispose];
    XCTAssertTrue(d.disposed == YES);

    id <RxDisposable> d3 = [r rx_retain];
    [d3 dispose];
}

- (void)testRefCountDisposable_PrimaryDisposesFirst {
    RxBooleanDisposable *d = [[RxBooleanDisposable alloc] init];
    RxRefCountDisposable *r = [[RxRefCountDisposable alloc] initWithDisposable:d];

    XCTAssertTrue(r.disposed == NO);

    id <RxDisposable> d1 = [r rx_retain];
    id <RxDisposable> d2 = [r rx_retain];

    XCTAssertTrue(d.disposed == NO);

    [d1 dispose];
    XCTAssertTrue(d.disposed == NO);

    [r dispose];
    XCTAssertTrue(d.disposed == NO);

    [d2 dispose];
    XCTAssertTrue(d.disposed == YES);
}

@end
