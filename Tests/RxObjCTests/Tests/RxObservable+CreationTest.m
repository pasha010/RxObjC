//
//  RxObservable+CreationTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 10.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"
#import <RxBlocking/RxBlockingObservable+Operators.h>
#import "XCTest+Rx.h"
#import "RxTestError.h"
#import "RxMockDisposable.h"

@interface RxObservableCreationTest : RxTest

@end

@implementation RxObservableCreationTest
@end

@implementation RxObservableCreationTest (Just)

- (void)testJust_Immediate {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable just:@42];
    }];

    NSArray *array = @[
            [self next:RxTestSchedulerDefaultSubscribed element:@42],
            [self completed:RxTestSchedulerDefaultSubscribed]
    ];

    XCTAssert([res.events isEqualToArray:array]);
}

- (void)testJust_Basic {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable just:@42 scheduler:scheduler];
    }];

    NSArray *array = @[
            [self next:201 element:@42],
            [self completed:202]
    ];

    XCTAssert([res.events isEqualToArray:array]);
}

- (void)testJust_Disposed {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler startWhenDisposed:200 create:^RxObservable * {
        return [RxObservable just:@42 scheduler:scheduler];
    }];

    XCTAssert([res.events isEqualToArray:@[]]);
}

- (void)testJust_DisposeAfterNext {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxSingleAssignmentDisposable *d = [[RxSingleAssignmentDisposable alloc] init];

    RxTestableObserver<NSNumber *> *res = [scheduler createObserver];

    [scheduler scheduleAt:100 action:^{
        d.disposable = [[RxObservable just:@42 scheduler:scheduler] subscribeWith:^(RxEvent<NSNumber *> *event) {
            [res on:event];
            if (event.type == RxEventTypeNext) {
                [d dispose];
            }
        }];
    }];

    [scheduler start];

    XCTAssert([res.events isEqualToArray:@[[self next:101 element:@42]]]);
}

- (void)testJust_DefaultScheduler {
    NSArray<NSNumber *> *res = [[[RxObservable just:@42 scheduler:[RxMainScheduler sharedInstance]] toBlocking] blocking_toArray];
    XCTAssert([res isEqualToArray:@[@42]]);
}

@end

@implementation RxObservableCreationTest (ToObservable)

- (void)testToObservable_complete_immediate {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler start:^RxObservable *{
        return [@[@3, @1, @2, @4] toObservable];
    }];

    NSArray *array = @[
        [self next:200 element:@3],
        [self next:200 element:@1],
        [self next:200 element:@2],
        [self next:200 element:@4],
        [self completed:200]
    ];
    XCTAssert([res.events isEqualToArray:array]);
}

- (void)testToObservable_complete {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler start:^RxObservable *{
        return [@[@3, @1, @2, @4] toObservable:scheduler];
    }];

    NSArray *array = @[
            [self next:201 element:@3],
            [self next:202 element:@1],
            [self next:203 element:@2],
            [self next:204 element:@4],
            [self completed:205]
    ];
    XCTAssert([res.events isEqualToArray:array]);
}

- (void)testToObservable_dispose {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler startWhenDisposed:203 create:^RxObservable * {
        return [@[@3, @1, @2, @4] toObservable:scheduler];
    }];

    NSArray *array = @[
            [self next:201 element:@3],
            [self next:202 element:@1],
    ];
    XCTAssert([res.events isEqualToArray:array]);
}

@end

@implementation RxObservableCreationTest (SequenceOf)

- (void)testSequenceOf_complete_immediate {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler start:^RxObservable *{
        return [RxObservable of:@[@3, @1, @2, @4]];
    }];

    NSArray *array = @[
            [self next:200 element:@3],
            [self next:200 element:@1],
            [self next:200 element:@2],
            [self next:200 element:@4],
            [self completed:200]
    ];
    XCTAssert([res.events isEqualToArray:array]);
}

- (void)testSequenceOf_complete {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler start:^RxObservable *{
        return [RxObservable of:@[@3, @1, @2, @4] scheduler:scheduler];
    }];

    NSArray *array = @[
            [self next:201 element:@3],
            [self next:202 element:@1],
            [self next:203 element:@2],
            [self next:204 element:@4],
            [self completed:205]
    ];
    XCTAssert([res.events isEqualToArray:array]);
}

- (void)testSequenceOf_dispose {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler startWhenDisposed:203 create:^RxObservable * {
        return [RxObservable of:@[@3, @1, @2, @4] scheduler:scheduler];
    }];

    NSArray *array = @[
            [self next:201 element:@3],
            [self next:202 element:@1],
    ];
    XCTAssert([res.events isEqualToArray:array]);
}

@end

@implementation RxObservableCreationTest (ToGenerate)

- (void)testGenerate_Finite {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable generate:@0 condition:^BOOL(NSNumber *__nonnull x) {
            return x.intValue <= 3;
        } scheduler:scheduler iterate:^NSNumber *(NSNumber *__nonnull x) {
            return @(x.integerValue + 1);
        }];
    }];
    NSArray *array = @[
            [self next:201 element:@0],
            [self next:202 element:@1],
            [self next:203 element:@2],
            [self next:204 element:@3],
            [self completed:205]
    ];
    XCTAssert([res.events isEqualToArray:array]);
}

- (void)testGenerate_ThrowCondition {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable generate:@0 condition:^BOOL(NSNumber *__nonnull x) {
            @throw [RxTestError testError];
        } scheduler:scheduler iterate:^NSNumber *(NSNumber *__nonnull x) {
            return @(x.integerValue + 1);
        }];
    }];
    NSArray *array = @[
            [self error:201 testError:[RxTestError testError]]
    ];
    XCTAssert([res.events isEqualToArray:array]);
}

- (void)testGenerate_ThrowIterate {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable generate:@0 condition:^BOOL(NSNumber *__nonnull x) {
            return YES;
        } scheduler:scheduler iterate:^NSNumber *(NSNumber *__nonnull x) {
            @throw [RxTestError testError];
            return @(x.integerValue + 1);
        }];
    }];
    
    NSArray *array = @[
            [self next:201 element:@0],
            [self error:202 testError:[RxTestError testError]]
    ];
    XCTAssert([res.events isEqualToArray:array]);
}

- (void)testGenerate_Dispose {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler startWhenDisposed:203 create:^RxObservable * {
        return [RxObservable generate:@0 condition:^BOOL(NSNumber *__nonnull x) {
            return YES;
        }                   scheduler:scheduler iterate:^NSNumber *(NSNumber *__nonnull x) {
            return @(x.integerValue + 1);
        }];
    }];
    NSArray *array = @[
            [self next:201 element:@0],
            [self next:202 element:@1],
    ];
    XCTAssert([res.events isEqualToArray:array]);
}

- (void)testGenerate_take {
    __block NSInteger count = 0;

    NSMutableArray<NSNumber *> *elements = [NSMutableArray array];

    [[[RxObservable generate:@0 condition:^BOOL(NSNumber *__nonnull x) {
        return YES;
    } iterate:^NSNumber *(NSNumber *__nonnull x) {
        count++;
        return @(x.integerValue + 1);
    }] take:4]
       subscribeNext:^(NSNumber *__nonnull x) {
           [elements addObject:x];
    }];

    NSArray *array = @[@0, @1, @2, @3];
    XCTAssert([elements isEqualToArray:array]);
    XCTAssert(count == 3);
}

@end

@implementation RxObservableCreationTest (Range)

- (void)testRange_Boundaries {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable range:@(NSUIntegerMax) count:1 scheduler:scheduler];
    }];

    NSArray *array = @[
            [self next:201 element:@(NSUIntegerMax)],
            [self completed:202]
    ];
    XCTAssert([res.events isEqualToArray:array]);
}

- (void)testRange_Dispose {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler startWhenDisposed:204 create:^RxObservable * {
        return [RxObservable range:@(-10) count:5 scheduler:scheduler];
    }];

    NSArray *array = @[
            [self next:201 element:@(-10)],
            [self next:202 element:@(-9)],
            [self next:203 element:@(-8)],
    ];
    XCTAssert([res.events isEqualToArray:array]);
}

@end

@implementation RxObservableCreationTest (RepeatElement)

- (void)testRepeat_Element {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObserver *res = [scheduler startWhenDisposed:207 create:^RxObservable * {
        return [RxObservable repeatElement:@42 scheduler:scheduler];
    }];

    NSArray *array = @[
            [self next:201 element:@42],
            [self next:202 element:@42],
            [self next:203 element:@42],
            [self next:204 element:@42],
            [self next:205 element:@42],
            [self next:206 element:@42],
    ];
    XCTAssert([res.events isEqualToArray:array]);
}

@end

@implementation RxObservableCreationTest (Using)

- (void)testUsing_Complete {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    
    __block NSInteger disposeInvoked = 0;
    __block NSInteger createInvoked = 0;
    
    __block RxTestableObservable<NSNumber *> *xs = nil;
    __block RxMockDisposable *disposable = nil;
    __block RxMockDisposable *_d = nil;

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable using:^RxMockDisposable * {
            disposeInvoked++;
            disposable = [[RxMockDisposable alloc] initWithScheduler:scheduler];
            return disposable;
        } observableFactory:^RxObservable *(id <RxDisposable> d) {
            _d = d;
            createInvoked++;
            xs = [scheduler createColdObservable:@[
                    [self next:100 element:scheduler.clock],
                    [self completed:200]
            ]];
            return [xs asObservable];
        }];
    }];
    
    XCTAssert(disposable == _d);

    NSArray *array = @[
            [self next:300 element:@200],
            [self completed:400]
    ];
    XCTAssert([res.events isEqualToArray:array]);

    XCTAssertEqual(1, createInvoked);
    XCTAssertEqual(1, disposeInvoked);

    XCTAssert([xs.subscriptions isEqualToArray:@[[RxSubscription createWithSubscribe:200 unsubscribe:400]]]);
    NSArray *ticks = @[@200, @400];
    XCTAssert([disposable.ticks isEqualToArray:ticks]);
}

- (void)testUsing_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block NSInteger disposeInvoked = 0;
    __block NSInteger createInvoked = 0;

    __block RxTestableObservable<NSNumber *> *xs = nil;
    __block RxMockDisposable *disposable = nil;
    __block RxMockDisposable *_d = nil;

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable using:^RxMockDisposable * {
            disposeInvoked++;
            disposable = [[RxMockDisposable alloc] initWithScheduler:scheduler];
            return disposable;
        } observableFactory:^RxObservable *(id <RxDisposable> d) {
            _d = d;
            createInvoked++;
            xs = [scheduler createColdObservable:@[
                    [self next:100 element:scheduler.clock],
                    [self error:200 testError:[RxTestError testError]]
            ]];
            return [xs asObservable];
        }];
    }];

    XCTAssert(disposable == _d);

    NSArray *array = @[
            [self next:300 element:@200],
            [self error:400 testError:[RxTestError testError]]
    ];
    XCTAssert([res.events isEqualToArray:array]);

    XCTAssertEqual(1, createInvoked);
    XCTAssertEqual(1, disposeInvoked);

    XCTAssert([xs.subscriptions isEqualToArray:@[[RxSubscription createWithSubscribe:200 unsubscribe:400]]]);

    NSArray *ticks = @[@200, @400];
    XCTAssert([disposable.ticks isEqualToArray:ticks]);
}

- (void)testUsing_Dispose {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block NSInteger disposeInvoked = 0;
    __block NSInteger createInvoked = 0;

    __block RxTestableObservable<NSNumber *> *xs = nil;
    __block RxMockDisposable *disposable = nil;
    __block RxMockDisposable *_d = nil;

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable using:^RxMockDisposable * {
            disposeInvoked++;
            disposable = [[RxMockDisposable alloc] initWithScheduler:scheduler];
            return disposable;
        } observableFactory:^RxObservable *(id <RxDisposable> d) {
            _d = d;
            createInvoked++;
            xs = [scheduler createColdObservable:@[
                    [self next:100 element:scheduler.clock],
                    [self next:1000 element:@(scheduler.clock.integerValue + 1)],
            ]];
            return [xs asObservable];
        }];
    }];

    XCTAssert(disposable == _d);

    NSArray *array = @[
            [self next:300 element:@200],
    ];
    XCTAssert([res.events isEqualToArray:array]);

    XCTAssertEqual(1, createInvoked);
    XCTAssertEqual(1, disposeInvoked);

    XCTAssert([xs.subscriptions isEqualToArray:@[[RxSubscription createWithSubscribe:200 unsubscribe:1000]]]);

    NSArray *ticks = @[@200, @1000];
    XCTAssert([disposable.ticks isEqualToArray:ticks]);
}

- (void)testUsing_ThrowResourceSelector {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block NSInteger disposeInvoked = 0;
    __block NSInteger createInvoked = 0;

    __block RxMockDisposable *disposable = nil;
    __block RxMockDisposable *_d = nil;

    RxTestableObserver<NSNumber *> *res = [scheduler start:^RxObservable * {
        return [RxObservable using:^RxMockDisposable * {
            disposeInvoked++;
            @throw [RxTestError testError];
        } observableFactory:^RxObservable *(id <RxDisposable> d) {
            createInvoked++;
            return [RxObservable never];
        }];
    }];

    XCTAssert(disposable == _d);

    NSArray *array = @[
            [self error:200 testError:[RxTestError testError]],
    ];
    XCTAssert([res.events isEqualToArray:array]);

    XCTAssertEqual(0, createInvoked);
    XCTAssertEqual(1, disposeInvoked);
}

- (void)testUsing_ThrowResourceUsage {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block NSInteger disposeInvoked = 0;
    __block NSInteger createInvoked = 0;

    __block RxMockDisposable *disposable = nil;

    RxTestableObserver<NSNumber *> *res = [scheduler start:^RxObservable * {
        return [RxObservable using:^RxMockDisposable * {
            disposeInvoked++;
            disposable = [[RxMockDisposable alloc] initWithScheduler:scheduler];
            return disposable;
        } observableFactory:^RxObservable *(id <RxDisposable> d) {
            createInvoked++;
            @throw [RxTestError testError];
        }];
    }];

    NSArray *array = @[
            [self error:200 testError:[RxTestError testError]],
    ];
    XCTAssert([res.events isEqualToArray:array]);

    XCTAssertEqual(1, createInvoked);
    XCTAssertEqual(1, disposeInvoked);

    NSArray *ticks = @[@200, @200];
    XCTAssert([disposable.ticks isEqualToArray:ticks]);
}

@end