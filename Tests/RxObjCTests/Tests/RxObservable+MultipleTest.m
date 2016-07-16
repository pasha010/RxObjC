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

- (void)testMerge_DeadlockSimple {
    __block NSInteger nEvents = 0;

    RxObservable *observable = [[RxObservable of:@[
            [RxObservable of:@[@0, @1, @2]],
            [RxObservable of:@[@0, @1, @2]],
            [RxObservable of:@[@0, @1, @2]],
    ]] merge];

    [observable subscribeNext:^(id o) {
        nEvents++;
    }];

    XCTAssertEqual(nEvents, 9);
}

- (void)testMerge_DeadlockErrorAfterN {
    __block NSInteger nEvents = 0;
    __block NSInteger eEvents = 0; // not in rxswift

    RxObservable *observable = [[RxObservable of:@[
            [RxObservable of:@[@0, @1, @2]],
            @[[RxObservable of:@[@0, @1]], [RxObservable error:testError()]].concat,
            [RxObservable of:@[@0, @1, @2]],
    ]] merge];

    [observable subscribeOnNext:^(id o) {
        nEvents++;
    } onError:^(NSError *error) {
        eEvents++;// not in rxswift
    }];

    XCTAssertEqual(nEvents, 5);// not in rxswift
    XCTAssertEqual(eEvents, 1);
}

- (void)testMerge_DeadlockErrorImmediatelly {
    __block NSInteger nEvents = 0;

    RxObservable *observable = [[RxObservable just:[RxObservable error:testError()]] merge];

    [observable subscribeError:^(NSError *error) {
        nEvents++;
    }];
    
    XCTAssertEqual(nEvents, 1);
}

- (void)testMerge_DeadlockEmpty {
    __block NSInteger nEvents = 0;

    RxObservable *observable = [[RxObservable empty] merge];
    [observable subscribeCompleted:^{
        nEvents++;
    }];
    XCTAssertEqual(nEvents, 1);
}

- (void)testMerge_DeadlockFirstEmpty {
    __block NSInteger nEvents = 0;

    RxObservable *observable = [[RxObservable just:[RxObservable empty]] merge];

    [observable subscribeCompleted:^{
        nEvents++;
    }];
    
    XCTAssertEqual(nEvents, 1);
}

- (void)testMergeConcurrent_DeadlockSimple {
    __block NSInteger nEvents = 0;

    RxObservable *observable = [[RxObservable of:@[
            [RxObservable of:@[@0, @1, @2]],
            [RxObservable of:@[@0, @1, @2]],
            [RxObservable of:@[@0, @1, @2]],
    ]] mergeWithMaxConcurrent:1];

    [observable subscribeNext:^(id o) {
        nEvents++;
    }];

    XCTAssertEqual(nEvents, 9);
}

- (void)testMergeConcurrent_DeadlockErrorAfterN {
    __block NSInteger nEvents = 0;

    RxObservable *observable = [[RxObservable of:@[
            [RxObservable of:@[@0, @1, @2]],
            @[[RxObservable of:@[@0, @1]], [RxObservable error:testError()]].concat,
            [RxObservable of:@[@0, @1, @2]],
    ]] mergeWithMaxConcurrent:1];

    [observable subscribeError:^(NSError *error) {
        nEvents++;
    }];

    XCTAssertEqual(nEvents, 1);
}

- (void)testMergeConcurrent_DeadlockErrorImmediatelly {
    __block NSInteger nEvents = 0;

    RxObservable *observable = [[RxObservable just:[RxObservable error:testError()]] mergeWithMaxConcurrent:1];
    
    [observable subscribeError:^(NSError *error) {
        nEvents++;
    }];

    XCTAssertEqual(nEvents, 1);
}

- (void)testMergeConcurrent_DeadlockEmpty {
    __block NSInteger nEvents = 0;

    RxObservable *observable = [[RxObservable empty] mergeWithMaxConcurrent:1];
    [observable subscribeCompleted:^{
        nEvents++;
    }];
    XCTAssertEqual(nEvents, 1);
}

- (void)testMergeConcurrent_DeadlockFirstEmpty {
    __block NSInteger nEvents = 0;

    RxObservable *observable = [[RxObservable just:[RxObservable empty]] mergeWithMaxConcurrent:1];

    [observable subscribeCompleted:^{
        nEvents++;
    }];

    XCTAssertEqual(nEvents, 1);
}

- (void)testMerge_ObservableOfObservable_Data {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *ys1 = [scheduler createColdObservable:@[
            next(10, @101),
            next(20, @102),
            next(110, @103),
            next(120, @104),
            next(210, @105),
            next(220, @106),
            completed(230) 
    ]];
    RxTestableObservable *ys2 = [scheduler createColdObservable:@[
            next(10, @201),
            next(20, @202),
            next(30, @203),
            next(40, @204),
            completed(50)
    ]];
    RxTestableObservable *ys3 = [scheduler createColdObservable:@[
            next(10, @301),
            next(20, @302),
            next(30, @303),
            next(40, @304),
            next(120, @305),
            completed(150)
    ]];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(300, ys1),
            next(400, ys2),
            next(500, ys3),
            completed(600)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs merge];
    }];

    NSArray *messages = @[
            next(310, @101),
            next(320, @102),
            next(410, @103),
            next(410, @201),
            next(420, @104),
            next(420, @202),
            next(430, @203),
            next(440, @204),
            next(510, @105),
            next(510, @301),
            next(520, @106),
            next(520, @302),
            next(530, @303),
            next(540, @304),
            next(620, @305),
            completed(650)
    ];
    XCTAssertEqualObjects(res.events, messages);

    XCTAssertEqualObjects(ys1.subscriptions, @[[RxSubscription createWithSubscribe:300 unsubscribe:530]]);

    XCTAssertEqualObjects(ys2.subscriptions, @[[RxSubscription createWithSubscribe:400 unsubscribe:450]]);

    XCTAssertEqualObjects(ys3.subscriptions, @[[RxSubscription createWithSubscribe:500 unsubscribe:650]]);
}

- (void)testMerge_ObservableOfObservable_Data_NotOverlapped {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *ys1 = [scheduler createColdObservable:@[
            next(10, @101),
            next(20, @102),
            completed(230)
    ]];
    RxTestableObservable *ys2 = [scheduler createColdObservable:@[
            next(10, @201),
            next(20, @202),
            next(30, @203),
            next(40, @204),
            completed(50)
    ]];
    RxTestableObservable *ys3 = [scheduler createColdObservable:@[
            next(10, @301),
            next(20, @302),
            next(30, @303),
            next(40, @304),
            completed(50)
    ]];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(300, ys1),
            next(400, ys2),
            next(500, ys3),
            completed(600)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs merge];
    }];

    NSArray *messages = @[
            next(310, @101),
            next(320, @102),
            next(410, @201),
            next(420, @202),
            next(430, @203),
            next(440, @204),
            next(510, @301),
            next(520, @302),
            next(530, @303),
            next(540, @304),
            completed(600)
    ];
    XCTAssertEqualObjects(res.events, messages);

    XCTAssertEqualObjects(xs.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:600]]);

    XCTAssertEqualObjects(ys1.subscriptions, @[[RxSubscription createWithSubscribe:300 unsubscribe:530]]);

    XCTAssertEqualObjects(ys2.subscriptions, @[[RxSubscription createWithSubscribe:400 unsubscribe:450]]);

    XCTAssertEqualObjects(ys3.subscriptions, @[[RxSubscription createWithSubscribe:500 unsubscribe:550]]);
}

- (void)testMerge_ObservableOfObservable_InnerThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *ys1 = [scheduler createColdObservable:@[
            next(10, @101),
            next(20, @102),
            next(110, @103),
            next(120, @104),
            next(210, @105),
            next(220, @106),
            completed(230)
    ]];
    RxTestableObservable *ys2 = [scheduler createColdObservable:@[
            next(10, @201),
            next(20, @202),
            next(30, @203),
            next(40, @204),
            error(50, testError1())
    ]];
    RxTestableObservable *ys3 = [scheduler createColdObservable:@[
            next(10, @301),
            next(20, @302),
            next(30, @303),
            next(40, @304),
            completed(150)
    ]];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(300, ys1),
            next(400, ys2),
            next(500, ys3),
            completed(600)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs merge];
    }];

    NSArray *messages = @[
            next(310, @101),
            next(320, @102),
            next(410, @103),
            next(410, @201),
            next(420, @104),
            next(420, @202),
            next(430, @203),
            next(440, @204),
            error(450, testError1())
    ];
    XCTAssertEqualObjects(res.events, messages);

    XCTAssertEqualObjects(xs.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:450]]);

    XCTAssertEqualObjects(ys1.subscriptions, @[[RxSubscription createWithSubscribe:300 unsubscribe:450]]);

    XCTAssertEqualObjects(ys2.subscriptions, @[[RxSubscription createWithSubscribe:400 unsubscribe:450]]);

    XCTAssertEqualObjects(ys3.subscriptions, @[]);
}

- (void)testMerge_ObservableOfObservable_OuterThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *ys1 = [scheduler createColdObservable:@[
            next(10, @101),
            next(20, @102),
            next(110, @103),
            next(120, @104),
            next(210, @105),
            next(220, @106),
            completed(230)
    ]];
    RxTestableObservable *ys2 = [scheduler createColdObservable:@[
            next(10, @201),
            next(20, @202),
            next(30, @203),
            next(40, @204),
            completed(50)
    ]];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(300, ys1),
            next(400, ys2),
            error(500, testError1()),
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs merge];
    }];

    NSArray *messages = @[
            next(310, @101),
            next(320, @102),
            next(410, @103),
            next(410, @201),
            next(420, @104),
            next(420, @202),
            next(430, @203),
            next(440, @204),
            error(500, testError1())
    ];
    XCTAssertEqualObjects(res.events, messages);

    XCTAssertEqualObjects(xs.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:500]]);

    XCTAssertEqualObjects(ys1.subscriptions, @[[RxSubscription createWithSubscribe:300 unsubscribe:500]]);

    XCTAssertEqualObjects(ys2.subscriptions, @[[RxSubscription createWithSubscribe:400 unsubscribe:450]]);
}

- (void)testMerge_MergeConcat_Basic {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *ys1 = [scheduler createColdObservable:@[
            next(50, @1),
            next(100, @2),
            next(120, @3),
            completed(140)
    ]];
    
    RxTestableObservable *ys2 = [scheduler createColdObservable:@[
            next(20, @4),
            next(70, @5),
            completed(200)
    ]];
    
    RxTestableObservable *ys3 = [scheduler createColdObservable:@[
            next(10, @6),
            next(90, @7),
            next(110, @8),
            completed(130)
    ]];
    
    RxTestableObservable *ys4 = [scheduler createColdObservable:@[
            next(210, @9),
            next(240, @10),
            completed(300)
    ]];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(320, ys4),
            completed(400)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs mergeWithMaxConcurrent:2];
    }];

    NSArray *messages = @[
            next(260, @1),
            next(280, @4),
            next(310, @2),
            next(330, @3),
            next(330, @5),
            next(360, @6),
            next(440, @7),
            next(460, @8),
            next(670, @9),
            next(700, @10),
            completed(760)
    ];
    XCTAssertEqualObjects(res.events, messages);

    XCTAssertEqualObjects(xs.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:400]]);

    XCTAssertEqualObjects(ys1.subscriptions, @[[RxSubscription createWithSubscribe:210 unsubscribe:350]]);

    XCTAssertEqualObjects(ys2.subscriptions, @[[RxSubscription createWithSubscribe:260 unsubscribe:460]]);

    XCTAssertEqualObjects(ys3.subscriptions, @[[RxSubscription createWithSubscribe:350 unsubscribe:480]]);

    XCTAssertEqualObjects(ys4.subscriptions, @[[RxSubscription createWithSubscribe:460 unsubscribe:760]]);

}

- (void)testMerge_MergeConcat_BasicLong {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *ys1 = [scheduler createColdObservable:@[
            next(50, @1),
            next(100, @2),
            next(120, @3),
            completed(140)
    ]];

    RxTestableObservable *ys2 = [scheduler createColdObservable:@[
            next(20, @4),
            next(70, @5),
            completed(300)
    ]];

    RxTestableObservable *ys3 = [scheduler createColdObservable:@[
            next(10, @6),
            next(90, @7),
            next(110, @8),
            completed(130)
    ]];

    RxTestableObservable *ys4 = [scheduler createColdObservable:@[
            next(210, @9),
            next(240, @10),
            completed(300)
    ]];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
                    next(210, ys1),
                    next(260, ys2),
                    next(270, ys3),
                    next(320, ys4),
                    completed(400)

    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs mergeWithMaxConcurrent:2];
    }];

    NSArray *messages = @[
            next(260, @1),
            next(280, @4),
            next(310, @2),
            next(330, @3),
            next(330, @5),
            next(360, @6),
            next(440, @7),
            next(460, @8),
            next(690, @9),
            next(720, @10),
            completed(780)
    ];
    XCTAssertEqualObjects(res.events, messages);

    XCTAssertEqualObjects(xs.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:400]]);

    XCTAssertEqualObjects(ys1.subscriptions, @[[RxSubscription createWithSubscribe:210 unsubscribe:350]]);

    XCTAssertEqualObjects(ys2.subscriptions, @[[RxSubscription createWithSubscribe:260 unsubscribe:560]]);

    XCTAssertEqualObjects(ys3.subscriptions, @[[RxSubscription createWithSubscribe:350 unsubscribe:480]]);

    XCTAssertEqualObjects(ys4.subscriptions, @[[RxSubscription createWithSubscribe:480 unsubscribe:780]]);
}

- (void)testMerge_MergeConcat_BasicWide {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *ys1 = [scheduler createColdObservable:@[
            next(50, @1),
            next(100, @2),
            next(120, @3),
            completed(140)
    ]];

    RxTestableObservable *ys2 = [scheduler createColdObservable:@[
            next(20, @4),
            next(70, @5),
            completed(300)
    ]];

    RxTestableObservable *ys3 = [scheduler createColdObservable:@[
            next(10, @6),
            next(90, @7),
            next(110, @8),
            completed(130)
    ]];

    RxTestableObservable *ys4 = [scheduler createColdObservable:@[
            next(210, @9),
            next(240, @10),
            completed(300)
    ]];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(420, ys4),
            completed(450)

    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs mergeWithMaxConcurrent:3];
    }];

    NSArray *messages = @[
            next(260, @1),
            next(280, @4),
            next(280, @6),
            next(310, @2),
            next(330, @3),
            next(330, @5),
            next(360, @7),
            next(380, @8),
            next(630, @9),
            next(660, @10),
            completed(720)
    ];
    XCTAssertEqualObjects(res.events, messages);

    XCTAssertEqualObjects(xs.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:450]]);

    XCTAssertEqualObjects(ys1.subscriptions, @[[RxSubscription createWithSubscribe:210 unsubscribe:350]]);

    XCTAssertEqualObjects(ys2.subscriptions, @[[RxSubscription createWithSubscribe:260 unsubscribe:560]]);

    XCTAssertEqualObjects(ys3.subscriptions, @[[RxSubscription createWithSubscribe:270 unsubscribe:400]]);

    XCTAssertEqualObjects(ys4.subscriptions, @[[RxSubscription createWithSubscribe:420 unsubscribe:720]]);
}

- (void)testMerge_MergeConcat_BasicLate {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *ys1 = [scheduler createColdObservable:@[
            next(50, @1),
            next(100, @2),
            next(120, @3),
            completed(140)
    ]];

    RxTestableObservable *ys2 = [scheduler createColdObservable:@[
            next(20, @4),
            next(70, @5),
            completed(300)
    ]];

    RxTestableObservable *ys3 = [scheduler createColdObservable:@[
            next(10, @6),
            next(90, @7),
            next(110, @8),
            completed(130)
    ]];

    RxTestableObservable *ys4 = [scheduler createColdObservable:@[
            next(210, @9),
            next(240, @10),
            completed(300)
    ]];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(420, ys4),
            completed(750)

    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs mergeWithMaxConcurrent:3];
    }];

    NSArray *messages = @[
            next(260, @1),
            next(280, @4),
            next(280, @6),
            next(310, @2),
            next(330, @3),
            next(330, @5),
            next(360, @7),
            next(380, @8),
            next(630, @9),
            next(660, @10),
            completed(750)
    ];
    XCTAssertEqualObjects(res.events, messages);

    XCTAssertEqualObjects(xs.subscriptions, @[[RxSubscription createWithSubscribe:200 unsubscribe:750]]);

    XCTAssertEqualObjects(ys1.subscriptions, @[[RxSubscription createWithSubscribe:210 unsubscribe:350]]);

    XCTAssertEqualObjects(ys2.subscriptions, @[[RxSubscription createWithSubscribe:260 unsubscribe:560]]);

    XCTAssertEqualObjects(ys3.subscriptions, @[[RxSubscription createWithSubscribe:270 unsubscribe:400]]);

    XCTAssertEqualObjects(ys4.subscriptions, @[[RxSubscription createWithSubscribe:420 unsubscribe:720]]);
}

- (void)testMerge_MergeConcat_Disposed {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *ys1 = [scheduler createColdObservable:@[
            next(50, @1),
            next(100, @2),
            next(120, @3),
            completed(140)
    ]];

    RxTestableObservable *ys2 = [scheduler createColdObservable:@[
            next(20, @4),
            next(70, @5),
            completed(200)
    ]];

    RxTestableObservable *ys3 = [scheduler createColdObservable:@[
            next(10, @6),
            next(90, @7),
            next(110, @8),
            completed(130)
    ]];

    RxTestableObservable *ys4 = [scheduler createColdObservable:@[
            next(210, @9),
            next(240, @10),
            completed(300)
    ]];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(320, ys4),
            completed(400)

    ]];

    RxTestableObserver *res = [scheduler startWhenDisposed:450 create:^RxObservable * {
        return [xs mergeWithMaxConcurrent:2];
    }];

    NSArray *messages = @[
            next(260, @1),
            next(280, @4),
            next(310, @2),
            next(330, @3),
            next(330, @5),
            next(360, @6),
            next(440, @7)
    ];
    XCTAssertEqualObjects(res.events, messages);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 400)]);

    XCTAssertEqualObjects(ys1.subscriptions, @[Subscription(210, 350)]);

    XCTAssertEqualObjects(ys2.subscriptions, @[Subscription(260, 450)]);

    XCTAssertEqualObjects(ys3.subscriptions, @[Subscription(350, 450)]);

    XCTAssertEqualObjects(ys4.subscriptions, @[]);
}

- (void)testMerge_MergeConcat_OuterError {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *ys1 = [scheduler createColdObservable:@[
            next(50, @1),
            next(100, @2),
            next(120, @3),
            completed(140)
    ]];

    RxTestableObservable *ys2 = [scheduler createColdObservable:@[
            next(20, @4),
            next(70, @5),
            completed(200)
    ]];

    RxTestableObservable *ys3 = [scheduler createColdObservable:@[
            next(10, @6),
            next(90, @7),
            next(110, @8),
            completed(130)
    ]];

    RxTestableObservable *ys4 = [scheduler createColdObservable:@[
            next(210, @9),
            next(240, @10),
            completed(300)
    ]];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(320, ys4),
            error(400, testError1())

    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs mergeWithMaxConcurrent:2];
    }];

    NSArray *messages = @[
            next(260, @1),
            next(280, @4),
            next(310, @2),
            next(330, @3),
            next(330, @5),
            next(360, @6),
            error(400, testError1())
    ];
    XCTAssertEqualObjects(res.events, messages);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 400)]);

    XCTAssertEqualObjects(ys1.subscriptions, @[Subscription(210, 350)]);

    XCTAssertEqualObjects(ys2.subscriptions, @[Subscription(260, 400)]);

    XCTAssertEqualObjects(ys3.subscriptions, @[Subscription(350, 400)]);

    XCTAssertEqualObjects(ys4.subscriptions, @[]);
}

- (void)testMerge_MergeConcat_InnerError {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *ys1 = [scheduler createColdObservable:@[
            next(50, @1),
            next(100, @2),
            next(120, @3),
            completed(140)
    ]];

    RxTestableObservable *ys2 = [scheduler createColdObservable:@[
            next(20, @4),
            next(70, @5),
            completed(200)
    ]];

    RxTestableObservable *ys3 = [scheduler createColdObservable:@[
            next(10, @6),
            next(90, @7),
            next(110, @8),
            error(140, testError1())
    ]];

    RxTestableObservable *ys4 = [scheduler createColdObservable:@[
            next(210, @9),
            next(240, @10),
            completed(300)
    ]];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(320, ys4),
            completed(400)

    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs mergeWithMaxConcurrent:2];
    }];

    NSArray *messages = @[
            next(260, @1),
            next(280, @4),
            next(310, @2),
            next(330, @3),
            next(330, @5),
            next(360, @6),
            next(440, @7),
            next(460, @8),
            error(490, testError1())
    ];
    XCTAssertEqualObjects(res.events, messages);

    XCTAssertEqualObjects(xs.subscriptions, @[Subscription(200, 400)]);

    XCTAssertEqualObjects(ys1.subscriptions, @[Subscription(210, 350)]);

    XCTAssertEqualObjects(ys2.subscriptions, @[Subscription(260, 460)]);

    XCTAssertEqualObjects(ys3.subscriptions, @[Subscription(350, 490)]);

    XCTAssertEqualObjects(ys4.subscriptions, @[Subscription(460, 490)]);
}

@end

@implementation RxObservableMultipleTest (CombineLatest)

- (void)testCombineLatest_DeadlockSimple {
    __block NSInteger nEvents = 0;
    RxObservable *observable = [RxObservable combineLatest:[RxObservable of:@[@0, @1, @2]] and:[RxObservable of:@[@0, @1, @2]] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
        return @(o1.integerValue + o2.integerValue);
    }];

    [observable subscribeNext:^(id o) {
        nEvents++;
    }];

    XCTAssertEqual(nEvents, 3);
}

- (void)testCombineLatest_DeadlockErrorAfterN {
    __block NSInteger nEvents = 0;
    RxObservable *observable = [RxObservable combineLatest:@[[RxObservable of:@[@0, @1, @2]], [RxObservable error:testError()]].concat
                                                       and:[RxObservable of:@[@0, @1, @2]]
                                            resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
                                                return @(o1.integerValue + o2.integerValue);
                                            }];

    [observable subscribeError:^(NSError *e) {
        nEvents++;
    }];

    XCTAssertEqual(nEvents, 1);
}

- (void)testCombineLatest_DeadlockErrorImmediatelly {
    __block NSInteger nEvents = 0;
    RxObservable *observable = [RxObservable combineLatest:[RxObservable error:testError()]
                                                       and:[RxObservable of:@[@0, @1, @2]]
                                            resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
                                                return @(o1.integerValue + o2.integerValue);
                                            }];

    [observable subscribeError:^(NSError *e) {
        nEvents++;
    }];

    XCTAssertEqual(nEvents, 1);
}

- (void)testReplay_DeadlockEmpty {
    __block NSInteger nEvents = 0;
    RxObservable *observable = [RxObservable combineLatest:[RxObservable empty]
                                                       and:[RxObservable of:@[@0, @1, @2]]
                                            resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
                                                return @(o1.integerValue + o2.integerValue);
                                            }];

    [observable subscribeCompleted:^{
        nEvents++;
    }];

    XCTAssertEqual(nEvents, 1);
}

@end

@implementation RxObservableMultipleTest (TakeUntil)

- (void)testTakeUntil_Preempt_SomeData_Next {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *l = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ]];

    RxTestableObservable *r = [scheduler createHotObservable:@[
            next(150, @1),
            next(225, @99),
            completed(230)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [l takeUntil:r];
    }];

    NSArray *events = @[
            next(210, @2),
            next(220, @3),
            completed(225)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(l.subscriptions, @[
            Subscription(200, 225)
    ]);

    XCTAssertEqualObjects(r.subscriptions, @[
            Subscription(200, 225)
    ]);
}

- (void)testTakeUntil_Preempt_SomeData_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *l = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ]];

    RxTestableObservable *r = [scheduler createHotObservable:@[
            next(150, @1),
            error(225, testError()),
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [l takeUntil:r];
    }];

    NSArray *events = @[
            next(210, @2),
            next(220, @3),
            error(225, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(l.subscriptions, @[
            Subscription(200, 225)
    ]);

    XCTAssertEqualObjects(r.subscriptions, @[
            Subscription(200, 225)
    ]);
}

- (void)testTakeUntil_NoPreempt_SomeData_Empty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *l = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ]];

    RxTestableObservable *r = [scheduler createHotObservable:@[
            next(150, @1),
            completed(225)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [l takeUntil:r];
    }];

    NSArray *events = @[
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(l.subscriptions, @[
            Subscription(200, 250)
    ]);

    XCTAssertEqualObjects(r.subscriptions, @[
            Subscription(200, 225)
    ]);
}


- (void)testTakeUntil_NoPreempt_SomeData_Never {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *l = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ]];

    RxTestableObservable *r = [scheduler createHotObservable:@[
            next(150, @1),
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [l takeUntil:r];
    }];

    NSArray *events = @[
            next(210, @2),
            next(220, @3),
            next(230, @4),
            next(240, @5),
            completed(250)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(l.subscriptions, @[
            Subscription(200, 250)
    ]);

    XCTAssertEqualObjects(r.subscriptions, @[
            Subscription(200, 250)
    ]);
}

- (void)testTakeUntil_Preempt_Never_Next {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *l = [scheduler createHotObservable:@[
            next(150, @1),
    ]];

    RxTestableObservable *r = [scheduler createHotObservable:@[
            next(150, @1),
            next(225, @2),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [l takeUntil:r];
    }];

    NSArray *events = @[
            completed(225)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(l.subscriptions, @[
            Subscription(200, 225)
    ]);

    XCTAssertEqualObjects(r.subscriptions, @[
            Subscription(200, 225)
    ]);
}

- (void)testTakeUntil_Preempt_Never_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *l = [scheduler createHotObservable:@[
            next(150, @1),
    ]];

    RxTestableObservable *r = [scheduler createHotObservable:@[
            next(150, @1),
            error(225, testError())
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [l takeUntil:r];
    }];

    NSArray *events = @[
            error(225, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(l.subscriptions, @[
            Subscription(200, 225)
    ]);

    XCTAssertEqualObjects(r.subscriptions, @[
            Subscription(200, 225)
    ]);
}

- (void)testTakeUntil_NoPreempt_Never_Empty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *l = [scheduler createHotObservable:@[
            next(150, @1),
    ]];

    RxTestableObservable *r = [scheduler createHotObservable:@[
            next(150, @1),
            completed(225)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [l takeUntil:r];
    }];

    NSArray *events = @[
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(l.subscriptions, @[
            Subscription(200, 1000)
    ]);

    XCTAssertEqualObjects(r.subscriptions, @[
            Subscription(200, 225)
    ]);
}

- (void)testTakeUntil_NoPreempt_Never_Never {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *l = [scheduler createHotObservable:@[
            next(150, @1),
    ]];

    RxTestableObservable *r = [scheduler createHotObservable:@[
            next(150, @1),
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [l takeUntil:r];
    }];

    NSArray *events = @[
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(l.subscriptions, @[
            Subscription(200, 1000)
    ]);

    XCTAssertEqualObjects(r.subscriptions, @[
            Subscription(200, 1000)
    ]);
}

- (void)testTakeUntil_Preempt_BeforeFirstProduced {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *l = [scheduler createHotObservable:@[
            next(150, @1),
            next(230, @2),
            completed(240)
    ]];

    RxTestableObservable *r = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            completed(220)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [l takeUntil:r];
    }];

    NSArray *events = @[
            completed(210)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(l.subscriptions, @[
            Subscription(200, 210)
    ]);

    XCTAssertEqualObjects(r.subscriptions, @[
            Subscription(200, 210)
    ]);
}

- (void)testTakeUntil_Preempt_BeforeFirstProduced_RemainSilentAndProperDisposed {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *l = [scheduler createHotObservable:@[
            next(150, @1),
            error(215, testError()),
            completed(240)
    ]];

    RxTestableObservable *r = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            completed(220)
    ]];

    __block BOOL sourceNotDisposed = NO;

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [[l doOn:^(RxEvent *event) {
            sourceNotDisposed = YES;
        }] takeUntil:r];
    }];

    NSArray *events = @[
            completed(210)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertFalse(sourceNotDisposed);
}

- (void)testTakeUntil_NoPreempt_AfterLastProduced_ProperDisposedSignal {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *l = [scheduler createHotObservable:@[
            next(150, @1),
            next(230, @2),
            completed(240)
    ]];

    RxTestableObservable *r = [scheduler createHotObservable:@[
            next(150, @1),
            next(250, @2),
            completed(260)
    ]];

    __block BOOL sourceNotDisposed = NO;

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [l takeUntil:[r doOn:^(RxEvent *event) {
            sourceNotDisposed = YES;
        }]];
    }];

    NSArray *events = @[
            next(230, @2),
            completed(240)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertFalse(sourceNotDisposed);
}

- (void)testTakeUntil_Error_Some {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *l = [scheduler createHotObservable:@[
            next(150, @1),
            error(225, testError())
    ]];

    RxTestableObservable *r = [scheduler createHotObservable:@[
            next(150, @1),
            next(240, @2),
    ]];

    __block BOOL sourceNotDisposed = NO;

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [l takeUntil:r];
    }];

    NSArray *events = @[
            error(225, testError()),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertFalse(sourceNotDisposed);
}

@end

@implementation RxObservableMultipleTest (Amb)

- (void)testAmb_Never2 {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *x1 = [scheduler createHotObservable:@[
            next(150, @1)
    ]];
    RxTestableObservable *x2 = [scheduler createHotObservable:@[
            next(150, @1)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [x1 amb:x2];
    }];

    NSArray *events = @[
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(x1.subscriptions, @[
            Subscription(200, 1000)
    ]);

    XCTAssertEqualObjects(x2.subscriptions, @[
            Subscription(200, 1000)
    ]);
}

- (void)testAmb_Never3 {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *x1 = [scheduler createHotObservable:@[
            next(150, @1)
    ]];

    RxTestableObservable *x2 = [scheduler createHotObservable:@[
            next(150, @1)
    ]];

    RxTestableObservable *x3 = [scheduler createHotObservable:@[
            next(150, @1)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [@[x1, x2, x3] amb];
    }];

    NSArray *events = @[
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(x1.subscriptions, @[
            Subscription(200, 1000)
    ]);

    XCTAssertEqualObjects(x2.subscriptions, @[
            Subscription(200, 1000)
    ]);

    XCTAssertEqualObjects(x3.subscriptions, @[
            Subscription(200, 1000)
    ]);
}

- (void)testAmb_Never_Empty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *x1 = [scheduler createHotObservable:@[
            next(150, @1)
    ]];
    RxTestableObservable *x2 = [scheduler createHotObservable:@[
            next(150, @1),
            completed(225)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [x1 amb:x2];
    }];

    NSArray *events = @[
            completed(225)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(x1.subscriptions, @[
            Subscription(200, 225)
    ]);

    XCTAssertEqualObjects(x2.subscriptions, @[
            Subscription(200, 225)
    ]);
}

- (void)testAmb_RegularShouldDisposeLoser {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *x1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            completed(240)
    ]];
    RxTestableObservable *x2 = [scheduler createHotObservable:@[
            next(150, @1),
            next(220, @3),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [x1 amb:x2];
    }];

    NSArray *events = @[
            next(210, @2),
            completed(240)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(x1.subscriptions, @[
            Subscription(200, 240)
    ]);

    XCTAssertEqualObjects(x2.subscriptions, @[
            Subscription(200, 210)
    ]);
}

- (void)testAmb_WinnerThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *x1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            error(220, testError())
    ]];
    RxTestableObservable *x2 = [scheduler createHotObservable:@[
            next(150, @1),
            next(220, @3),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [x1 amb:x2];
    }];

    NSArray *events = @[
            next(210, @2),
            error(220, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(x1.subscriptions, @[
            Subscription(200, 220)
    ]);

    XCTAssertEqualObjects(x2.subscriptions, @[
            Subscription(200, 210)
    ]);
}

- (void)testAmb_LoserThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *x1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(220, @2),
            error(220, testError())
    ]];
    RxTestableObservable *x2 = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @3),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [x1 amb:x2];
    }];

    NSArray *events = @[
            next(210, @3),
            completed(250)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(x1.subscriptions, @[
            Subscription(200, 210)
    ]);

    XCTAssertEqualObjects(x2.subscriptions, @[
            Subscription(200, 250)
    ]);
}

- (void)testAmb_ThrowsBeforeElectionLeft {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *x1 = [scheduler createHotObservable:@[
            next(150, @1),
            error(210, testError())
    ]];
    RxTestableObservable *x2 = [scheduler createHotObservable:@[
            next(150, @1),
            next(220, @3),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [x1 amb:x2];
    }];

    NSArray *events = @[
            error(210, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(x1.subscriptions, @[
            Subscription(200, 210)
    ]);

    XCTAssertEqualObjects(x2.subscriptions, @[
            Subscription(200, 210)
    ]);
}

- (void)testAmb_ThrowsBeforeElectionRight {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *x1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(220, @3),
            completed(250)
    ]];
    RxTestableObservable *x2 = [scheduler createHotObservable:@[
            next(150, @1),
            error(210, testError())
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [x1 amb:x2];
    }];

    NSArray *events = @[
            error(210, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(x1.subscriptions, @[
            Subscription(200, 210)
    ]);

    XCTAssertEqualObjects(x2.subscriptions, @[
            Subscription(200, 210)
    ]);
}

@end

@implementation RxObservableMultipleTest (CombineLatest_CollectionType)

- (void)testCombineLatest_NeverN {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1)
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1)
    ]];

    RxTestableObservable *e2 = [scheduler createHotObservable:@[
            next(150, @1)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [@[e0, e1, e2] combineLatest:^NSNumber *(NSArray<NSNumber *> *array) {
            return [[array objectEnumerator] reduce:@0 combine:NSCombinePlus()];
        }];
    }];

    NSArray *events = @[
    ];

    XCTAssertEqualObjects(res.events, events);

    for (RxTestableObservable *e in @[e0, e1, e2]) {
        XCTAssertEqualObjects(e.subscriptions, @[
                Subscription(200, 1000)
        ]);
    }
}

- (void)testCombineLatest_NeverEmptyN {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1)
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            completed(210)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [@[e0, e1] combineLatest:^NSNumber *(NSArray<NSNumber *> *array) {
            return [[array objectEnumerator] reduce:@0 combine:NSCombinePlus()];
        }];
    }];

    NSArray *events = @[
    ];

    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 1000)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 210)]);
}

@end
