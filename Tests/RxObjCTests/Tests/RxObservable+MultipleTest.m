//
//  RxObservable+MultipleTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"

@interface RxObservableMultipleTest : RxTest

@end

@implementation RxObservableMultipleTest

@end

@implementation RxObservableMultipleTest (CatchError)

- (void)testCatch_ErrorSpecific_Caught {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *o1 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self next:210 element:@2],
            [self next:220 element:@3],
            [self error:230 testError:[RxTestError testError]],
    ]];
    
    RxTestableObservable *o2 = [scheduler createHotObservable:@[
            [self next:240 element:@4],
            [self completed:250]
    ]];
    
    __block NSNumber *handlerCalled = nil;

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [o1 catchError:^RxObservable *(NSError *error) {
            handlerCalled = scheduler.clock;
            return [o2 asObservable];
        }];
    }];
    
    XCTAssert([handlerCalled isEqualToNumber:@230]);

    BOOL b = [res.events isEqualToArray:@[
            [self next:210 element:@2],
            [self next:220 element:@3],
            [self next:240 element:@4],
            [self completed:250]
    ]];
    XCTAssert(b);

    XCTAssert([o1.subscriptions isEqualToArray:@[
            [RxSubscription createWithSubscribe:200 unsubscribe:230]
    ]]);

    XCTAssert([o2.subscriptions isEqualToArray:@[
            [RxSubscription createWithSubscribe:230 unsubscribe:250]
    ]]);
}

- (void)testCatch_HandlerThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *o1 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self next:210 element:@2],
            [self next:220 element:@3],
            [self error:230 testError:[RxTestError testError]],
    ]];

    __block NSNumber *handlerCalled = nil;

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [o1 catchError:^RxObservable *(NSError *error) {
            handlerCalled = scheduler.clock;
            @throw [RxTestError testError1];
        }];
    }];

    XCTAssert([handlerCalled isEqualToNumber:@230]);

    BOOL b = [res.events isEqualToArray:@[
            [self next:210 element:@2],
            [self next:220 element:@3],
            [self error:230 testError:[RxTestError testError1]],
    ]];
    XCTAssert(b);

    XCTAssert([o1.subscriptions isEqualToArray:@[
            [RxSubscription createWithSubscribe:200 unsubscribe:230]
    ]]);
}

@end

@implementation RxObservableMultipleTest (CatchEnumerable)

- (void)testCatchSequenceOf_IEofIO {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createColdObservable:@[
            [self next:10 element:@1],
            [self next:20 element:@2],
            [self next:30 element:@3],
            [self error:40 testError:[RxTestError testError]]
    ]];
    
    RxTestableObservable *xs2 = [scheduler createColdObservable:@[
            [self next:10 element:@4],
            [self next:20 element:@5],
            [self error:30 testError:[RxTestError testError]]
    ]];
    
    RxTestableObservable *xs3 = [scheduler createColdObservable:@[
            [self next:10 element:@6],
            [self next:20 element:@7],
            [self next:30 element:@8],
            [self next:40 element:@9],
            [self completed:50]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [@[xs1, xs2, xs3] catchError];
    }];

    BOOL b = [res.events isEqualToArray:@[
            [self next:210 element:@1],
            [self next:220 element:@2],
            [self next:230 element:@3],
            [self next:250 element:@4],
            [self next:260 element:@5],
            [self next:280 element:@6],
            [self next:290 element:@7],
            [self next:300 element:@8],
            [self next:310 element:@9],
            [self completed:320]
    ]];
    XCTAssert(b);

    XCTAssert([xs1.subscriptions isEqualToArray:@[
            [RxSubscription createWithSubscribe:200 unsubscribe:240]
    ]]);

    XCTAssert([xs2.subscriptions isEqualToArray:@[
            [RxSubscription createWithSubscribe:240 unsubscribe:270]
    ]]);

    XCTAssert([xs3.subscriptions isEqualToArray:@[
            [RxSubscription createWithSubscribe:270 unsubscribe:320]
    ]]);
}

- (void)testCatchAnySequence_NoErrors {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self next:210 element:@2],
            [self next:220 element:@3],
            [self completed:230]
    ]];
    RxTestableObservable *xs2 = [scheduler createHotObservable:@[
            [self next:240 element:@4],
            [self completed:250]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [@[xs1, xs2] catchError];
    }];

    BOOL b = [res.events isEqualToArray:@[
            [self next:210 element:@2],
            [self next:220 element:@3],
            [self completed:230]
    ]];
    XCTAssert(b);

    XCTAssert([xs1.subscriptions isEqualToArray:@[
            [RxSubscription createWithSubscribe:200 unsubscribe:230]
    ]]);

    XCTAssert([xs2.subscriptions isEqualToArray:@[]]);
}

- (void)testCatchAnySequence_Never {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
    ]];
    RxTestableObservable *xs2 = [scheduler createHotObservable:@[
            [self next:240 element:@4],
            [self completed:250]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [@[xs1, xs2] catchError];
    }];

    BOOL b = [res.events isEqualToArray:@[]];
    XCTAssert(b);

    XCTAssert([xs1.subscriptions isEqualToArray:@[
            [RxSubscription createWithSubscribe:200 unsubscribe:1000]
    ]]);
    XCTAssert([xs2.subscriptions isEqualToArray:@[]]);
}

- (void)testCatchAnySequence_Empty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self completed:230]
    ]];
    RxTestableObservable *xs2 = [scheduler createHotObservable:@[
            [self next:240 element:@4],
            [self completed:250]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [@[xs1, xs2] catchError];
    }];

    BOOL b = [res.events isEqualToArray:@[
            [self completed:230]
    ]];
    XCTAssert(b);

    XCTAssert([xs1.subscriptions isEqualToArray:@[
            [RxSubscription createWithSubscribe:200 unsubscribe:230]
    ]]);
    XCTAssert([xs2.subscriptions isEqualToArray:@[]]);
}

- (void)testCatchSequenceOf_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self next:210 element:@2],
            [self next:220 element:@3],
            [self error:230 testError:[RxTestError testError]]
    ]];
    RxTestableObservable *xs2 = [scheduler createHotObservable:@[
            [self next:240 element:@4],
            [self completed:250]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [@[xs1, xs2] catchError];
    }];

    BOOL b = [res.events isEqualToArray:@[
            [self next:210 element:@2],
            [self next:220 element:@3],
            [self next:240 element:@4],
            [self completed:250]
    ]];
    XCTAssert(b);

    XCTAssert([xs1.subscriptions isEqualToArray:@[
            [RxSubscription createWithSubscribe:200 unsubscribe:230]
    ]]);
    XCTAssert([xs2.subscriptions isEqualToArray:@[
            [RxSubscription createWithSubscribe:230 unsubscribe:250]
    ]]);
}

- (void)testCatchSequenceOf_ErrorNever {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self next:210 element:@2],
            [self next:220 element:@3],
            [self error:230 testError:[RxTestError testError]]
    ]];
    RxTestableObservable *xs2 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [@[xs1, xs2] catchError];
    }];

    BOOL b = [res.events isEqualToArray:@[
            [self next:210 element:@2],
            [self next:220 element:@3],
    ]];
    XCTAssert(b);

    XCTAssert([xs1.subscriptions isEqualToArray:@[
            [RxSubscription createWithSubscribe:200 unsubscribe:230]
    ]]);
    XCTAssert([xs2.subscriptions isEqualToArray:@[
            [RxSubscription createWithSubscribe:230 unsubscribe:1000]
    ]]);
}

- (void)testCatchSequenceOf_ErrorError {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self next:210 element:@2],
            [self next:220 element:@3],
            [self error:230 testError:[RxTestError testError]]
    ]];
    RxTestableObservable *xs2 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self error:250 testError:[RxTestError testError]]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [@[xs1, xs2] catchError];
    }];

    BOOL b = [res.events isEqualToArray:@[
            [self next:210 element:@2],
            [self next:220 element:@3],
            [self error:250 testError:[RxTestError testError]]
    ]];
    XCTAssert(b);

    XCTAssert([xs1.subscriptions isEqualToArray:@[
            [RxSubscription createWithSubscribe:200 unsubscribe:230]
    ]]);
    XCTAssert([xs2.subscriptions isEqualToArray:@[
            [RxSubscription createWithSubscribe:230 unsubscribe:250]
    ]]);
}

- (void)testCatchSequenceOf_Multiple {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self next:210 element:@2],
            [self error:215 testError:[RxTestError testError]]
    ]];
    RxTestableObservable *xs2 = [scheduler createHotObservable:@[
            [self next:220 element:@3],
            [self error:225 testError:[RxTestError testError]]
    ]];
    RxTestableObservable *xs3 = [scheduler createHotObservable:@[
            [self next:230 element:@4],
            [self completed:235]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [@[xs1, xs2, xs3] catchError];
    }];

    BOOL b = [res.events isEqualToArray:@[
            [self next:210 element:@2],
            [self next:220 element:@3],
            [self next:230 element:@4],
            [self completed:235]
    ]];
    XCTAssert(b);

    XCTAssert([xs1.subscriptions isEqualToArray:@[
            [RxSubscription createWithSubscribe:200 unsubscribe:215]
    ]]);
    XCTAssert([xs2.subscriptions isEqualToArray:@[
            [RxSubscription createWithSubscribe:215 unsubscribe:225]
    ]]);
    XCTAssert([xs3.subscriptions isEqualToArray:@[
            [RxSubscription createWithSubscribe:225 unsubscribe:235]
    ]]);
}

@end

@implementation RxObservableMultipleTest (Switch)
@end

@implementation RxObservableMultipleTest (Concat)

- (void)testConcat_DefaultScheduler {
    __block int sum = 0;
    [[@[[RxObservable just:@1], [RxObservable just:@2], [RxObservable just:@3]] concat] subscribeNext:^(NSNumber *e) {
        sum += e.intValue;
    }];

    XCTAssertTrue(sum == 6, @"sum = %d", sum);
}

- (void)testConcat_IEofIO {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createColdObservable:@[
            [self next:10 element:@1],
            [self next:20 element:@2],
            [self next:30 element:@3],
            [self completed:40]
    ]];

    RxTestableObservable *xs2 = [scheduler createColdObservable:@[
            [self next:10 element:@4],
            [self next:20 element:@5],
            [self completed:30]
    ]];

    RxTestableObservable *xs3 = [scheduler createColdObservable:@[
            [self next:10 element:@6],
            [self next:20 element:@7],
            [self next:30 element:@8],
            [self next:40 element:@9],
            [self completed:50]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return @[xs1, xs2, xs3].concat;
    }];

    NSArray *messages = @[
            [self next:210 element:@1],
            [self next:220 element:@2],
            [self next:230 element:@3],
            [self next:250 element:@4],
            [self next:260 element:@5],
            [self next:280 element:@6],
            [self next:290 element:@7],
            [self next:300 element:@8],
            [self next:310 element:@9],
            [self completed:320]
    ];

    XCTAssertTrue([res.events isEqualToArray:messages]);

    XCTAssertTrue([xs1.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:200 unsubscribe:240]]]);
    XCTAssertTrue([xs2.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:240 unsubscribe:270]]]);
    XCTAssertTrue([xs3.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:270 unsubscribe:320]]]);
}

- (void)testConcat_EmptyEmpty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self completed:230]
    ]];

    RxTestableObservable *xs2 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self completed:250]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return @[xs1, xs2].concat;
    }];

    XCTAssertTrue([res.events isEqualToArray:@[[self completed:250]]]);
    XCTAssertTrue([xs1.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:200 unsubscribe:230]]]);
    XCTAssertTrue([xs2.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:230 unsubscribe:250]]]);
}

// TODO complete this

@end
