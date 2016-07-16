//
//  RxObservable+MultipleTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"
#import "RxLazyEnumerator.h"

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

- (void)testSwitch_Data {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *ys1 = [scheduler createColdObservable:@[
            [self next:10 element:@101],
            [self next:20 element:@102],
            [self next:110 element:@103],
            [self next:120 element:@104],
            [self next:210 element:@105],
            [self next:220 element:@106],
            [self completed:230]
    ]];
    
    RxTestableObservable *ys2 = [scheduler createColdObservable:@[
            [self next:10 element:@201],
            [self next:20 element:@202],
            [self next:30 element:@203],
            [self next:40 element:@204],
            [self completed:50]
    ]];
    
    RxTestableObservable *ys3 = [scheduler createColdObservable:@[
            [self next:10 element:@301],
            [self next:20 element:@302],
            [self next:30 element:@303],
            [self next:40 element:@304],
            [self completed:150]
    ]];

    NSArray *xSequence = @[
            [self next:300 element:ys1],
            [self next:400 element:ys2],
            [self next:500 element:ys3],
            [self completed:600]
    ];

    RxTestableObservable *xs = [scheduler createHotObservable:xSequence];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs switchLatest];
    }];

    NSArray *correct = @[
            [self next:310 element:@101],
            [self next:320 element:@102],
            [self next:410 element:@201],
            [self next:420 element:@202],
            [self next:430 element:@203],
            [self next:440 element:@204],
            [self next:510 element:@301],
            [self next:520 element:@302],
            [self next:530 element:@303],
            [self next:540 element:@304],   
            [self completed:650]
    ];

    XCTAssertEqualObjects(res.events, correct);

    XCTAssertEqualObjects(xs.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:600]]);

    XCTAssertEqualObjects(ys1.subscriptions, @[[RxSubscription createWithSubscribe:300 unsubscribe:400]]);

    XCTAssertEqualObjects(ys2.subscriptions, @[[RxSubscription createWithSubscribe:400 unsubscribe:450]]);

    XCTAssertEqualObjects(ys3.subscriptions, @[[RxSubscription createWithSubscribe:500 unsubscribe:650]]);
}

- (void)testSwitch_InnerThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *ys1 = [scheduler createColdObservable:@[
            [self next:10 element:@101],
            [self next:20 element:@102],
            [self next:110 element:@103],
            [self next:120 element:@104],
            [self next:210 element:@105],
            [self next:220 element:@106],
            [self completed:230],
    ]];
    RxTestableObservable *ys2 = [scheduler createColdObservable:@[
            [self next:10 element:@201],
            [self next:20 element:@202],
            [self next:30 element:@203],
            [self next:40 element:@204],
            [self error:50 testError:[RxTestError testError]],
    ]];
    RxTestableObservable *ys3 = [scheduler createColdObservable:@[
            [self next:10 element:@301],
            [self next:20 element:@302],
            [self next:30 element:@303],
            [self next:40 element:@304],
            [self completed:150],
    ]];

    NSArray *xSequence = @[
            [self next:300 element:ys1],
            [self next:400 element:ys2],
            [self next:500 element:ys3],
            [self completed:600],
    ];

    RxTestableObservable *xs = [scheduler createHotObservable:xSequence];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs switchLatest];
    }];

    NSArray *correct = @[
            [self next:310 element:@101],
            [self next:320 element:@102],
            [self next:410 element:@201],
            [self next:420 element:@202],
            [self next:430 element:@203],
            [self next:440 element:@204],
            [self error:450 testError:[RxTestError testError]],
    ];
    XCTAssertEqualObjects(res.events, correct);

    XCTAssertEqualObjects(xs.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:450]]);

    XCTAssertEqualObjects(ys1.subscriptions, @[[RxSubscription createWithSubscribe:300 unsubscribe:400]]);

    XCTAssertEqualObjects(ys2.subscriptions, @[[RxSubscription createWithSubscribe:400 unsubscribe:450]]);

    XCTAssertEqualObjects(ys3.subscriptions, @[]);
}

- (void)testSwitch_OuterThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *ys1 = [scheduler createColdObservable:@[
            [self next:10 element:@101],
            [self next:20 element:@102],
            [self next:110 element:@103],
            [self next:120 element:@104],
            [self next:210 element:@105],
            [self next:220 element:@106],
            [self completed:230],
    ]];
    RxTestableObservable *ys2 = [scheduler createColdObservable:@[
            [self next:10 element:@201],
            [self next:20 element:@202],
            [self next:30 element:@203],
            [self next:40 element:@204],
            [self completed:50],
    ]];

    NSArray *xSequence = @[
            [self next:300 element:ys1],
            [self next:400 element:ys2],
            [self error:500 testError:[RxTestError testError]],
    ];

    RxTestableObservable *xs = [scheduler createHotObservable:xSequence];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs switchLatest];
    }];

    NSArray *correct = @[
            [self next:310 element:@101],
            [self next:320 element:@102],
            [self next:410 element:@201],
            [self next:420 element:@202],
            [self next:430 element:@203],
            [self next:440 element:@204],
            [self error:500 testError:[RxTestError testError]],
    ];
    XCTAssertEqualObjects(res.events, correct);

    XCTAssertEqualObjects(xs.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:500]]);

    XCTAssertEqualObjects(ys1.subscriptions, @[[RxSubscription createWithSubscribe:300 unsubscribe:400]]);

    XCTAssertEqualObjects(ys2.subscriptions, @[[RxSubscription createWithSubscribe:400 unsubscribe:450]]);
}

@end

@implementation RxObservableMultipleTest (FlatMapLatest)

- (void)testFlatMapLatest_Data {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *ys1 = [scheduler createColdObservable:@[
            [self next:10 element:@101],
            [self next:20 element:@102],
            [self next:110 element:@103],
            [self next:120 element:@104],
            [self next:210 element:@105],
            [self next:220 element:@106],
            [self completed:230],
    ]]; 
    
    RxTestableObservable *ys2 = [scheduler createColdObservable:@[
            [self next:10 element:@201],
            [self next:20 element:@202],
            [self next:30 element:@203],
            [self next:40 element:@204],
            [self completed:50],
    ]];
    
    RxTestableObservable *ys3 = [scheduler createColdObservable:@[
            [self next:10 element:@301],
            [self next:20 element:@302],
            [self next:30 element:@303],
            [self next:40 element:@304],
            [self completed:150],
    ]];

    NSArray<RxTestableObservable *> *observables = @[ys1, ys2, ys3];

    NSArray *xSequence = @[
            [self next:300 element:@0],
            [self next:400 element:@1],
            [self next:500 element:@2],
            [self completed:600]
    ];

    RxTestableObservable *xs = [scheduler createHotObservable:xSequence];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs flatMapLatest:^id <RxObservableConvertibleType>(NSNumber *index) {
            return observables[index.unsignedIntegerValue];
        }];
    }];

    NSArray *correct = @[
            [self next:310 element:@101],
            [self next:320 element:@102],
            [self next:410 element:@201],
            [self next:420 element:@202],
            [self next:430 element:@203],
            [self next:440 element:@204],
            [self next:510 element:@301],
            [self next:520 element:@302],
            [self next:530 element:@303],
            [self next:540 element:@304],
            [self completed:650],
    ];

    XCTAssertEqualObjects(res.events, correct);

    XCTAssertEqualObjects(xs.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:600]]);

    XCTAssertEqualObjects(ys1.subscriptions, @[[RxSubscription createWithSubscribe:300 unsubscribe:400]]);

    XCTAssertEqualObjects(ys2.subscriptions, @[[RxSubscription createWithSubscribe:400 unsubscribe:450]]);

    XCTAssertEqualObjects(ys3.subscriptions, @[[RxSubscription createWithSubscribe:500 unsubscribe:650]]);

}

- (void)testFlatMapLatest_InnerThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *ys1 = [scheduler createColdObservable:@[
            [self next:10 element:@101],
            [self next:20 element:@102],
            [self next:110 element:@103],
            [self next:120 element:@104],
            [self next:210 element:@105],
            [self next:220 element:@106],
            [self completed:230],
    ]];

    RxTestableObservable *ys2 = [scheduler createColdObservable:@[
            [self next:10 element:@201],
            [self next:20 element:@202],
            [self next:30 element:@203],
            [self next:40 element:@204],
            [self error:50 testError:[RxTestError testError]]
    ]];

    RxTestableObservable *ys3 = [scheduler createColdObservable:@[
            [self next:10 element:@301],
            [self next:20 element:@302],
            [self next:30 element:@303],
            [self next:40 element:@304],
            [self completed:150],
    ]];

    NSArray<RxTestableObservable *> *observables = @[ys1, ys2, ys3];

    NSArray *xSequence = @[
            [self next:300 element:@0],
            [self next:400 element:@1],
            [self next:500 element:@2],
            [self completed:600]
    ];

    RxTestableObservable *xs = [scheduler createHotObservable:xSequence];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs flatMapLatest:^id <RxObservableConvertibleType>(NSNumber *index) {
            return observables[index.unsignedIntegerValue];
        }];
    }];

    NSArray *correct = @[
            [self next:310 element:@101],
            [self next:320 element:@102],
            [self next:410 element:@201],
            [self next:420 element:@202],
            [self next:430 element:@203],
            [self next:440 element:@204],
            [self error:450 testError:[RxTestError testError]]
    ];

    XCTAssertEqualObjects(res.events, correct);

    XCTAssertEqualObjects(xs.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:450]]);

    XCTAssertEqualObjects(ys1.subscriptions, @[[RxSubscription createWithSubscribe:300 unsubscribe:400]]);

    XCTAssertEqualObjects(ys2.subscriptions, @[[RxSubscription createWithSubscribe:400 unsubscribe:450]]);

    XCTAssertEqualObjects(ys3.subscriptions, @[]);
}

- (void)testFlatMapLatest_OuterThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *ys1 = [scheduler createColdObservable:@[
            [self next:10 element:@101],
            [self next:20 element:@102],
            [self next:110 element:@103],
            [self next:120 element:@104],
            [self next:210 element:@105],
            [self next:220 element:@106],
            [self completed:230],
    ]];

    RxTestableObservable *ys2 = [scheduler createColdObservable:@[
            [self next:10 element:@201],
            [self next:20 element:@202],
            [self next:30 element:@203],
            [self next:40 element:@204],
            [self completed:50]
    ]];

    NSArray<RxTestableObservable *> *observables = @[ys1, ys2];

    NSArray *xSequence = @[
            [self next:300 element:@0],
            [self next:400 element:@1],
            [self error:500 testError:[RxTestError testError]]
    ];

    RxTestableObservable *xs = [scheduler createHotObservable:xSequence];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs flatMapLatest:^id <RxObservableConvertibleType>(NSNumber *index) {
            return observables[index.unsignedIntegerValue];
        }];
    }];

    NSArray *correct = @[
            [self next:310 element:@101],
            [self next:320 element:@102],
            [self next:410 element:@201],
            [self next:420 element:@202],
            [self next:430 element:@203],
            [self next:440 element:@204],
            [self error:500 testError:[RxTestError testError]]
    ];

    XCTAssertEqualObjects(res.events, correct);

    XCTAssertEqualObjects(xs.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:500]]);

    XCTAssertEqualObjects(ys1.subscriptions, @[[RxSubscription createWithSubscribe:300 unsubscribe:400]]);

    XCTAssertEqualObjects(ys2.subscriptions, @[[RxSubscription createWithSubscribe:400 unsubscribe:450]]);
}

- (void)testFlatMapLatest_SelectorThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *ys1 = [scheduler createColdObservable:@[
            [self next:10 element:@101],
            [self next:20 element:@102],
            [self next:110 element:@103],
            [self next:120 element:@104],
            [self next:210 element:@105],
            [self next:220 element:@106],
            [self completed:230],
    ]];

    RxTestableObservable *ys2 = [scheduler createColdObservable:@[
            [self next:10 element:@201],
            [self next:20 element:@202],
            [self next:30 element:@203],
            [self next:40 element:@204],
            [self completed:50]
    ]];

    NSArray<RxTestableObservable *> *observables = @[ys1, ys2];

    NSArray *xSequence = @[
            [self next:300 element:@0],
            [self next:400 element:@1],
    ];

    RxTestableObservable *xs = [scheduler createHotObservable:xSequence];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs flatMapLatest:^id <RxObservableConvertibleType>(NSNumber *index) {
            if (index.integerValue < 1) {
                return observables[index.unsignedIntegerValue];
            } else {
                @throw [RxTestError testError];
            }
        }];
    }];

    NSArray *correct = @[
            [self next:310 element:@101],
            [self next:320 element:@102],
            [self error:400 testError:[RxTestError testError]]
    ];

    XCTAssertEqualObjects(res.events, correct);

    XCTAssertEqualObjects(xs.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:400]]);

    XCTAssertEqualObjects(ys1.subscriptions, @[[RxSubscription createWithSubscribe:300 unsubscribe:400]]);

    XCTAssertEqualObjects(ys2.subscriptions, @[]);
}

@end

@implementation RxObservableMultipleTest (Concat)

- (void)testConcat_DefaultScheduler {
    __block int sum = 0;
    [[@[[RxObservable just:@1], [RxObservable just:@2], [RxObservable just:@3]] concat] subscribeNext:^(NSNumber *e) {
        sum += e.intValue;
    }];

    XCTAssertEqual(sum, 6);
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

    XCTAssertEqualObjects(res.events, @[[self completed:250]]);
    XCTAssertEqualObjects(xs1.subscriptions, @[[[RxSubscription alloc] initWithSubscribe:200 unsubscribe:230]]);
    XCTAssertEqualObjects(xs2.subscriptions, @[[[RxSubscription alloc] initWithSubscribe:230 unsubscribe:250]]);
}

- (void)testConcat_EmptyNever {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self completed:230]
    ]];

    RxTestableObservable *xs2 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return @[xs1, xs2].concat;
    }];

    NSArray<RxRecorded <RxEvent<NSNumber *> *> *> *messages = @[];

    XCTAssertEqualObjects(res.events, messages);
    XCTAssertEqualObjects(xs1.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:230]]);
    XCTAssertEqualObjects(xs2.subscriptions, @[[RxSubscription createWithSubscribe:230 unsubscribe:1000]]);
}

- (void)testConcat_NeverNever {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
    ]];

    RxTestableObservable *xs2 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return @[xs1, xs2].concat;
    }];

    NSArray<RxRecorded <RxEvent<NSNumber *> *> *> *messages = @[];

    XCTAssertEqualObjects(res.events, messages);
    XCTAssertEqualObjects(xs1.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:1000]]);
    XCTAssertEqualObjects(xs2.subscriptions, @[]);
}

- (void)testConcat_EmptyThrow {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self completed:230]
    ]];

    RxTestableObservable *xs2 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self error:250 testError:[RxTestError testError]]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return @[xs1, xs2].concat;
    }];

    NSArray<RxRecorded <RxEvent<NSNumber *> *> *> *messages = @[
            [self error:250 testError:[RxTestError testError]]
    ];

    XCTAssertEqualObjects(res.events, messages);
    XCTAssertEqualObjects(xs1.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:230]]);
    XCTAssertEqualObjects(xs2.subscriptions, @[[RxSubscription createWithSubscribe:230 unsubscribe:250]]);
}

- (void)testConcat_ThrowEmpty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self error:230 testError:[RxTestError testError]]
    ]];

    RxTestableObservable *xs2 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self completed:250]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return @[xs1, xs2].concat;
    }];

    NSArray<RxRecorded <RxEvent<NSNumber *> *> *> *messages = @[
            [self error:230 testError:[RxTestError testError]]
    ];

    XCTAssertEqualObjects(res.events, messages);
    XCTAssertEqualObjects(xs1.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:230]]);
    XCTAssertEqualObjects(xs2.subscriptions, @[]);
}

- (void)testConcat_ThrowThrow {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self error:230 testError:[RxTestError testError1]]
    ]];

    RxTestableObservable *xs2 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self error:250 testError:[RxTestError testError2]]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return @[xs1, xs2].concat;
    }];

    NSArray<RxRecorded <RxEvent<NSNumber *> *> *> *messages = @[
            [self error:230 testError:[RxTestError testError1]]
    ];

    XCTAssertEqualObjects(res.events, messages);
    XCTAssertEqualObjects(xs1.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:230]]);
    XCTAssertEqualObjects(xs2.subscriptions, @[]);
}

- (void)testConcat_ReturnEmpty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self next:210 element:@2],
            [self completed:230],
    ]];

    RxTestableObservable *xs2 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self completed:250]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return @[xs1, xs2].concat;
    }];

    NSArray<RxRecorded <RxEvent<NSNumber *> *> *> *messages = @[
            [self next:210 element:@2],
            [self completed:250]
    ];

    XCTAssertEqualObjects(res.events, messages);
    XCTAssertEqualObjects(xs1.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:230]]);
    XCTAssertEqualObjects(xs2.subscriptions, @[[RxSubscription createWithSubscribe:230 unsubscribe:250]]);
}

- (void)testConcat_EmptyReturn {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self completed:230],
    ]];

    RxTestableObservable *xs2 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self next:240 element:@2],
            [self completed:250]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return @[xs1, xs2].concat;
    }];

    NSArray<RxRecorded <RxEvent<NSNumber *> *> *> *messages = @[
            [self next:240 element:@2],
            [self completed:250]
    ];

    XCTAssertEqualObjects(res.events, messages);
    XCTAssertEqualObjects(xs1.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:230]]);
    XCTAssertEqualObjects(xs2.subscriptions, @[[RxSubscription createWithSubscribe:230 unsubscribe:250]]);
}

- (void)testConcat_ReturnNever {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self next:210 element:@2],
            [self completed:230],
    ]];

    RxTestableObservable *xs2 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return @[xs1, xs2].concat;
    }];

    NSArray<RxRecorded <RxEvent<NSNumber *> *> *> *messages = @[
            [self next:210 element:@2],
    ];

    XCTAssertEqualObjects(res.events, messages);
    XCTAssertEqualObjects(xs1.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:230]]);
    XCTAssertEqualObjects(xs2.subscriptions, @[[RxSubscription createWithSubscribe:230 unsubscribe:1000]]);
}

- (void)testConcat_NeverReturn {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
    ]];

    RxTestableObservable *xs2 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self next:210 element:@2],
            [self completed:230],

    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return @[xs1, xs2].concat;
    }];

    NSArray<RxRecorded <RxEvent<NSNumber *> *> *> *messages = @[
    ];

    XCTAssertEqualObjects(res.events, messages);
    XCTAssertEqualObjects(xs1.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:1000]]);
    XCTAssertEqualObjects(xs2.subscriptions, @[]);
}

- (void)testConcat_ReturnReturn {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self next:220 element:@2],
            [self completed:230]
    ]];

    RxTestableObservable *xs2 = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self next:240 element:@3],
            [self completed:250],

    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return @[xs1, xs2].concat;
    }];

    NSArray<RxRecorded <RxEvent<NSNumber *> *> *> *messages = @[
            next(220, @2),
            next(240, @3),
            completed(250)
    ];

    XCTAssertEqualObjects(res.events, messages);
    XCTAssertEqualObjects(xs1.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:230]]);
    XCTAssertEqualObjects(xs2.subscriptions, @[[RxSubscription createWithSubscribe:230 unsubscribe:250]]);
}

- (void)testConcat_ThrowReturn {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            next(150, @1),
            error(230, [RxTestError testError1])
    ]];

    RxTestableObservable *xs2 = [scheduler createHotObservable:@[
            next(150, @1),
            next(240, @2),
            completed(250)

    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return @[xs1, xs2].concat;
    }];

    NSArray<RxRecorded <RxEvent<NSNumber *> *> *> *messages = @[
            error(230, [RxTestError testError1])
    ];

    XCTAssertEqualObjects(res.events, messages);
    XCTAssertEqualObjects(xs1.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:230]]);
    XCTAssertEqualObjects(xs2.subscriptions, @[]);
}

- (void)testConcat_ReturnThrow {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(220, @2),
            completed(230),
    ]];

    RxTestableObservable *xs2 = [scheduler createHotObservable:@[
            next(150, @1),
            error(250, testError2())
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return @[xs1, xs2].concat;
    }];

    NSArray<RxRecorded <RxEvent<NSNumber *> *> *> *messages = @[
            next(220, @2),
            error(250, testError2())
    ];

    XCTAssertEqualObjects(res.events, messages);
    XCTAssertEqualObjects(xs1.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:230]]);
    XCTAssertEqualObjects(xs2.subscriptions, @[[RxSubscription createWithSubscribe:230 unsubscribe:250]]);
}

- (void)testConcat_SomeDataSomeData {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            completed(225),
    ]];

    RxTestableObservable *xs2 = [scheduler createHotObservable:@[
            next(150, @1),
            next(230, @4),
            next(240, @5),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return @[xs1, xs2].concat;
    }];

    NSArray<RxRecorded <RxEvent<NSNumber *> *> *> *messages = @[
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ];

    XCTAssertEqualObjects(res.events, messages);
    XCTAssertEqualObjects(xs1.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:225]]);
    XCTAssertEqualObjects(xs2.subscriptions, @[[RxSubscription createWithSubscribe:225 unsubscribe:250]]);
}

- (void)testConcat_EnumerableTiming {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            completed(230)
    ]];
    
    RxTestableObservable *xs2 = [scheduler createColdObservable:@[
            next(50, @4),
            next(60, @5),
            next(70, @6),
            completed(80)
    ]];
    
    RxTestableObservable *xs3 = [scheduler createHotObservable:@[
            next(150, @1),
            next(200, @2),
            next(210, @3),
            next(220, @4),
            next(230, @5),
            next(270, @6),
            next(320, @7),
            next(330, @8),
            completed(340)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return @[xs1.asObservable, xs2.asObservable, xs3.asObservable, xs2.asObservable].concat;
    }];

    NSArray *messages = @[
            next(210, @2),
            next(220, @3),
            next(280, @4),
            next(290, @5),
            next(300, @6),
            next(320, @7),
            next(330, @8),
            next(390, @4),
            next(400, @5),
            next(410, @6),
            completed(420)   
    ];
    
    XCTAssertEqualObjects(res.events, messages);
    
    XCTAssertEqualObjects(xs1.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:230]]);

    NSArray *xs2sub = @[
            [RxSubscription createWithSubscribe:230 unsubscribe:310],
            [RxSubscription createWithSubscribe:340 unsubscribe:420],
    ];
    XCTAssertEqualObjects(xs2.subscriptions, xs2sub);

    XCTAssertEqualObjects(xs3.subscriptions, @[[RxSubscription createWithSubscribe:310 unsubscribe:340]]);
}

#ifdef TRACE_RESOURCES

RxObservable *generateCollection(NSUInteger startIndex, RxObservable *(^generator)(NSUInteger)) {
    NSMutableArray *all = [NSMutableArray array];
    for (NSUInteger j = 0; j < 2; j++) {
        [all addObject:^id {
            RxObservable *observable = j == 0 ? generator(startIndex) : generateCollection(startIndex + 1, generator);
            return observable;
        }];
    }
    return [[[RxLazyEnumerator alloc] initWithObjects:all] concat:all.count];
}


- (void)testConcat_TailRecursionCollection {
    rx_maxTailRecursiveSinkStackSize = 0;
    NSArray *elements = [[[generateCollection(0, ^RxObservable *(NSUInteger i) {
        return [RxObservable just:@(i) scheduler:[RxCurrentThreadScheduler sharedInstance]];
    }) take:10000] toBlocking] blocking_toArray];

    NSMutableArray<NSNumber *> *array = [NSMutableArray arrayWithCapacity:10000];
    for (NSUInteger i = 0; i < 10000; i++) {
        [array addObject:@(i)];
    }
    XCTAssertEqualObjects(elements, array);
    XCTAssertEqual(rx_maxTailRecursiveSinkStackSize, 1);
}
#endif

@end

@implementation RxObservableMultipleTest (Merge)
@end
