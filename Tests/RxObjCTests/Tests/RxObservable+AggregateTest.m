//
//  RxObservable+AggregateTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RxObservable+Aggregate.h"
#import "RxTestScheduler.h"
#import "XCTest+Rx.h"
#import "RxTestableObservable.h"
#import "RxTestableObserver.h"
#import "RxSubscription.h"
#import "RxTestError.h"
#import "RxObservable+StandardSequenceOperators.h"
#import "RxEquatableArray.h"

@interface RxObservableAggregateTest : XCTestCase
@end

@implementation RxObservableAggregateTest
@end

@implementation RxObservableAggregateTest (Reduce)

- (void)test_AggregateWithSeed_Empty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self completed:250]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs reduce:@42 accumulator:^NSNumber *(NSNumber *o, NSNumber *e) {
            return @(o.intValue + e.intValue);
        }];
    }];

    NSArray *correctMessages = @[[self next:250 element:@42], [self completed:250]];
    XCTAssertTrue([res.events isEqualToArray:correctMessages]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:RxTestSchedulerDefaultSubscribed unsubscribe:250]]]);
}

- (void)test_AggregateWithSeed_Return {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self next:210 element:@24],
            [self completed:250]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs reduce:@42 accumulator:^NSNumber *(NSNumber *o, NSNumber *e) {
            return @(o.intValue + e.intValue);
        }];
    }];

    NSArray *correctMessages = @[[self next:250 element:@(42 + 24)], [self completed:250]];
    XCTAssertTrue([res.events isEqualToArray:correctMessages]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:RxTestSchedulerDefaultSubscribed unsubscribe:250]]]);
}

- (void)test_AggregateWithSeed_Throw {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self error:210 testError:[RxTestError testError]]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs reduce:@42 accumulator:^NSNumber *(NSNumber *o, NSNumber *e) {
            return @(o.intValue + e.intValue);
        }];
    }];

    NSArray *correctMessages = @[[self error:210 testError:[RxTestError testError]]];
    XCTAssertTrue([res.events isEqualToArray:correctMessages]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:RxTestSchedulerDefaultSubscribed unsubscribe:210]]]);
}

- (void)test_AggregateWithSeed_Never {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    
    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:150 element:@1],
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs reduce:@42 accumulator:^NSNumber *(NSNumber *o, NSNumber *e) {
            return @(o.intValue + e.intValue);
        }];
    }];

    NSArray *correctMessages = @[];
    XCTAssertTrue([res.events isEqualToArray:correctMessages]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:RxTestSchedulerDefaultSubscribed unsubscribe:RxTestSchedulerDefaultDisposed]]]);
}

- (void)test_AggregateWithSeed_Range {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:150 element:@1], // ignore this value
            [self next:210 element:@0],
            [self next:220 element:@1],
            [self next:230 element:@2],
            [self next:240 element:@3],
            [self next:250 element:@4],
            [self completed:260]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs reduce:@42 accumulator:^NSNumber *(NSNumber *o, NSNumber *e) {
            return @(o.intValue + e.intValue);
        }];
    }];

    NSArray *correctMessages = @[
            [self next:260 element:@(42 + 0 + 1 + 2 + 3 + 4)], 
            [self completed:260]];
    XCTAssertTrue([res.events isEqualToArray:correctMessages]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:RxTestSchedulerDefaultSubscribed unsubscribe:260]]]);
}

- (void)test_AggregateWithSeed_AccumulatorThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:150 element:@1], // ignore this value
            [self next:210 element:@0],
            [self next:220 element:@1],
            [self next:230 element:@2],
            [self next:240 element:@3],
            [self next:250 element:@4],
            [self completed:260]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs reduce:@42 accumulator:^NSNumber *(NSNumber *aNumber, NSNumber *xNumber) {
            int a = aNumber.intValue;
            int x = xNumber.intValue;
            if (x < 3) {
                return @(a + x);
            }
            @throw [RxTestError testError];
        }];
    }];

    NSArray *correctMessages = @[[self error:240 testError:[RxTestError testError]]];
    XCTAssertTrue([res.events isEqualToArray:correctMessages]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:RxTestSchedulerDefaultSubscribed unsubscribe:240]]]);
}

- (void)test_AggregateWithSeedAndResult_Empty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self completed:250]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs reduce:@42 accumulator:^NSNumber *(NSNumber *o, NSNumber *e) {
            return @(o.intValue + e.intValue);
        } mapResult:^RxResultType(NSNumber *o) {
            return @(o.intValue * 5);
        }];
    }];

    NSArray *correctMessages = @[
            [self next:250 element:@(42 * 5)],
            [self completed:250]];
    XCTAssertTrue([res.events isEqualToArray:correctMessages]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:RxTestSchedulerDefaultSubscribed unsubscribe:250]]]);
}

- (void)test_AggregateWithSeedAndResult_Return {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self next:210 element:@24],
            [self completed:250]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs reduce:@42 accumulator:^NSNumber *(NSNumber *o, NSNumber *e) {
            return @(o.intValue + e.intValue);
        } mapResult:^RxResultType(NSNumber *o) {
            return @(o.intValue * 5);
        }];
    }];

    NSArray *correctMessages = @[
            [self next:250 element:@((42 + 24) * 5)],
            [self completed:250]];
    XCTAssertTrue([res.events isEqualToArray:correctMessages]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:RxTestSchedulerDefaultSubscribed unsubscribe:250]]]);
}

- (void)test_AggregateWithSeedAndResult_Throw {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self error:210 testError:[RxTestError testError]],
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs reduce:@42 accumulator:^NSNumber *(NSNumber *o, NSNumber *e) {
            return @(o.intValue + e.intValue);
        } mapResult:^RxResultType(NSNumber *o) {
            return @(o.intValue * 5);
        }];
    }];

    NSArray *correctMessages = @[[self error:210 testError:[RxTestError testError]]];
    XCTAssertTrue([res.events isEqualToArray:correctMessages]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:RxTestSchedulerDefaultSubscribed unsubscribe:210]]]);
}

- (void)test_AggregateWithSeedAndResult_Never {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:150 element:@1],
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs reduce:@42 accumulator:^NSNumber *(NSNumber *o, NSNumber *e) {
            return @(o.intValue + e.intValue);
        } mapResult:^RxResultType(NSNumber *o) {
            return @(o.intValue * 5);
        }];
    }];

    NSArray *correctMessages = @[];
    XCTAssertTrue([res.events isEqualToArray:correctMessages]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:RxTestSchedulerDefaultSubscribed unsubscribe:RxTestSchedulerDefaultDisposed]]]);
}

- (void)test_AggregateWithSeedAndResult_Range {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:150 element:@1], // ignore this value
            [self next:210 element:@0],
            [self next:220 element:@1],
            [self next:230 element:@2],
            [self next:240 element:@3],
            [self next:250 element:@4],
            [self completed:260]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs reduce:@42 accumulator:^NSNumber *(NSNumber *o, NSNumber *e) {
            return @(o.intValue + e.intValue);
        } mapResult:^RxResultType(NSNumber *o) {
            return @(o.intValue * 5);
        }];
    }];

    NSArray *correctMessages = @[
            [self next:260 element:@((42 + 0 + 1 + 2 + 3 + 4) * 5)],
            [self completed:260]
    ];
    XCTAssertTrue([res.events isEqualToArray:correctMessages]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:RxTestSchedulerDefaultSubscribed unsubscribe:260]]]);
}

- (void)test_AggregateWithSeedAndResult_AccumulatorThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:150 element:@1], // ignore this value
            [self next:210 element:@0],
            [self next:220 element:@1],
            [self next:230 element:@2],
            [self next:240 element:@3],
            [self next:250 element:@4],
            [self completed:260]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs reduce:@42 accumulator:^NSNumber *(NSNumber *o, NSNumber *e) {
            int a = o.intValue;
            int x = e.intValue;
            if (x < 3) {
                return @(a + x);
            }
            @throw [RxTestError testError];
        } mapResult:^RxResultType(NSNumber *o) {
            return @(o.intValue * 5);
        }];
    }];

    NSArray *correctMessages = @[[self error:240 testError:[RxTestError testError]]];
    XCTAssertTrue([res.events isEqualToArray:correctMessages]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:RxTestSchedulerDefaultSubscribed unsubscribe:240]]]);
}

- (void)test_AggregateWithSeedAndResult_SelectorThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:150 element:@1], // ignore this value
            [self next:210 element:@0],
            [self next:220 element:@1],
            [self next:230 element:@2],
            [self next:240 element:@3],
            [self next:250 element:@4],
            [self completed:260]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs reduce:@42 accumulator:^NSNumber *(NSNumber *o, NSNumber *e) {
            return @(o.intValue + e.intValue);
        } mapResult:^RxResultType(NSNumber *o) {
            @throw [RxTestError testError];
        }];
    }];

    NSArray *correctMessages = @[[self error:260 testError:[RxTestError testError]]];
    XCTAssertTrue([res.events isEqualToArray:correctMessages]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:RxTestSchedulerDefaultSubscribed
                                                                                   unsubscribe:260]]]);

}

@end

@implementation RxObservableAggregateTest (ToArray)

- (void)test_ToArrayWithSingleItem_Return {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            [self next:10 element:@1],
            [self completed:20]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [[xs toArray] map:^RxEquatableArray *(NSArray *o) {
            return [[RxEquatableArray alloc] initWithElements:o];
        }];
    }];

    NSArray *correctMessages = @[
            [self next:220 element:[[RxEquatableArray alloc] initWithElements:@[@1]]],
            [self completed:220]
    ];
    XCTAssertTrue([res.events isEqualToArray:correctMessages]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[ [[RxSubscription alloc] initWithSubscribe:RxTestSchedulerDefaultSubscribed unsubscribe:220] ]]);
}

- (void)test_ToArrayWithMultipleItems_Return {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            [self next:10 element:@1],
            [self next:20 element:@2],
            [self next:30 element:@3],
            [self next:40 element:@4],
            [self completed:50]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [[xs toArray] map:^RxEquatableArray *(NSArray *o) {
            return [[RxEquatableArray alloc] initWithElements:o];
        }];
    }];

    NSArray *correctMessages = @[
            [self next:250 element:[[RxEquatableArray alloc] initWithElements:@[@1, @2, @3, @4]]],
            [self completed:250]
    ];
    XCTAssertTrue([res.events isEqualToArray:correctMessages]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[ [[RxSubscription alloc] initWithSubscribe:RxTestSchedulerDefaultSubscribed
                                                                                    unsubscribe:250] ]]);
}

- (void)test_ToArrayWithNoItems_Empty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            [self completed:50]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [[xs toArray] map:^RxEquatableArray *(NSArray *o) {
            return [[RxEquatableArray alloc] initWithElements:o];
        }];
    }];

    NSArray *correctMessages = @[
            [self next:250 element:[[RxEquatableArray alloc] initWithElements:@[]]],
            [self completed:250]
    ];
    XCTAssertTrue([res.events isEqualToArray:correctMessages]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[ [[RxSubscription alloc] initWithSubscribe:RxTestSchedulerDefaultSubscribed
                                                                                    unsubscribe:250] ]]);
}

- (void)test_ToArrayWithSingleItem_Never {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            [self next:150 element:@1]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [[xs toArray] map:^RxEquatableArray *(NSArray *o) {
            return [[RxEquatableArray alloc] initWithElements:o];
        }];
    }];

    NSArray *correctMessages = @[];
    XCTAssertTrue([res.events isEqualToArray:correctMessages]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[ [[RxSubscription alloc] initWithSubscribe:RxTestSchedulerDefaultSubscribed
                                                                                    unsubscribe:RxTestSchedulerDefaultDisposed] ]]);
}

- (void)test_ToArrayWithImmediateError_Throw {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            [self error:10 testError:[RxTestError testError]]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [[xs toArray] map:^RxEquatableArray *(NSArray *o) {
            return [[RxEquatableArray alloc] initWithElements:o];
        }];
    }];

    NSArray *correctMessages = @[
            [self error:210 testError:[RxTestError testError]],
    ];
    XCTAssertTrue([res.events isEqualToArray:correctMessages]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[ [[RxSubscription alloc] initWithSubscribe:RxTestSchedulerDefaultSubscribed
                                                                                    unsubscribe:210] ]]);
}

- (void)test_ToArrayWithMultipleItems_Throw {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createColdObservable:@[
            [self next:10 element:@1],
            [self next:20 element:@2],
            [self next:30 element:@3],
            [self next:40 element:@4],
            [self error:50 testError:[RxTestError testError]]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [[xs toArray] map:^RxEquatableArray *(NSArray *o) {
            return [[RxEquatableArray alloc] initWithElements:o];
        }];
    }];

    NSArray *correctMessages = @[
            [self error:250 testError:[RxTestError testError]]
    ];
    XCTAssertTrue([res.events isEqualToArray:correctMessages]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[ [[RxSubscription alloc] initWithSubscribe:RxTestSchedulerDefaultSubscribed
                                                                                    unsubscribe:250] ]]);
}

@end
