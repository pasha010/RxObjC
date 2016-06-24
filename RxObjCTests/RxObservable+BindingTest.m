//
//  RxObservableBindingTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RxObservable+Binding.h"
#import "RxTest.h"
#import "RxTestScheduler.h"
#import "XCTest+Rx.h"
#import "RxTestableObservable.h"
#import "RxPublishSubject.h"
#import "RxTestableObserver.h"
#import "RxSubscription.h"
#import "RxTestError.h"
#import "RxObservable+Zip.h"
#import "RxObservable+Creation.h"
#import "RxObservable+Multiple.h"

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCDFAInspection"
@interface RxObservableBindingTest : RxTest

@end

@implementation RxObservableBindingTest

#pragma mark - multicast

- (void)testMulticast_Cold_Completed {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable<NSNumber *> *xs = [scheduler createHotObservable:@[
            [self next:40 element:@0],
            [self next:90 element:@1],
            [self next:150 element:@2],
            [self next:210 element:@3],
            [self next:240 element:@4],
            [self next:270 element:@5],
            [self next:330 element:@6],
            [self next:340 element:@7],
            [self completed:390]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs multicast:^id <RxSubjectType> {
            return [RxPublishSubject create];
        } selector:^RxObservable *(RxObservable *observable) {
            return observable;
        }];
    }];

    NSArray<RxRecorded <RxEvent<NSNumber *> *> *> *array = @[
            [self next:210 element:@3],
            [self next:240 element:@4],
            [self next:270 element:@5],
            [self next:330 element:@6],
            [self next:340 element:@7],
            [self completed:390]
    ];
    XCTAssertTrue([res.events isEqualToArray:array]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:200 unsubscribe:390]]]);
}

- (void)testMulticast_Cold_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable<NSNumber *> *xs = [scheduler createHotObservable:@[
            [self next:40 element:@0],
            [self next:90 element:@1],
            [self next:150 element:@2],
            [self next:210 element:@3],
            [self next:240 element:@4],
            [self next:270 element:@5],
            [self next:330 element:@6],
            [self next:340 element:@7],
            [self error:390 testError:[RxTestError testError]]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs multicast:^id <RxSubjectType> {
            return [RxPublishSubject create];
        } selector:^RxObservable *(RxObservable *observable) {
            return observable;
        }];
    }];

    NSArray<RxRecorded <RxEvent<NSNumber *> *> *> *array = @[
            [self next:210 element:@3],
            [self next:240 element:@4],
            [self next:270 element:@5],
            [self next:330 element:@6],
            [self next:340 element:@7],
            [self error:390 testError:[RxTestError testError]]
    ];
    XCTAssertTrue([res.events isEqualToArray:array]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:200 unsubscribe:390]]]);
}

- (void)testMulticast_Cold_Dispose {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable<NSNumber *> *xs = [scheduler createHotObservable:@[
            [self next:40 element:@0],
            [self next:90 element:@1],
            [self next:150 element:@2],
            [self next:210 element:@3],
            [self next:240 element:@4],
            [self next:270 element:@5],
            [self next:330 element:@6],
            [self next:340 element:@7],
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs multicast:^id <RxSubjectType> {
            return [RxPublishSubject create];
        } selector:^RxObservable *(RxObservable *observable) {
            return observable;
        }];
    }];

    NSArray<RxRecorded <RxEvent<NSNumber *> *> *> *array = @[
            [self next:210 element:@3],
            [self next:240 element:@4],
            [self next:270 element:@5],
            [self next:330 element:@6],
            [self next:340 element:@7],
    ];
    XCTAssertTrue([res.events isEqualToArray:array]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:200 unsubscribe:1000]]]);
}

- (void)testMulticast_Cold_Zip {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable<NSNumber *> *xs = [scheduler createHotObservable:@[
            [self next:40 element:@0],
            [self next:90 element:@1],
            [self next:150 element:@2],
            [self next:210 element:@3],
            [self next:240 element:@4],
            [self next:270 element:@5],
            [self next:330 element:@6],
            [self next:340 element:@7],
            [self completed:390]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs multicast:^id <RxSubjectType> {
            return [RxPublishSubject create];
        } selector:^RxObservable *(RxObservable *observable) {
            return [RxObservable zip:observable and:observable resultSelector:^NSNumber *(NSNumber *a, NSNumber *b) {
                return @(a.intValue + b.intValue);
            }];
        }];
    }];

    NSArray<RxRecorded <RxEvent<NSNumber *> *> *> *array = @[
            [self next:210 element:@6],
            [self next:240 element:@8],
            [self next:270 element:@10],
            [self next:330 element:@12],
            [self next:340 element:@14],
            [self completed:390]
    ];
    XCTAssertTrue([res.events isEqualToArray:array]);

    XCTAssertTrue([xs.subscriptions isEqualToArray:@[[[RxSubscription alloc] initWithSubscribe:200 unsubscribe:390]]]);
}

- (void)testMulticast_SubjectSelectorThrowsError {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:210 element:@1],
            [self next:240 element:@2],
            [self completed:300]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs multicast:^id <RxSubjectType> {
            @throw [RxTestError testError];
            return [RxPublishSubject create];
        } selector:^RxObservable *(RxObservable *observable) {
            return observable;
        }];
    }];

    XCTAssertTrue([res.events isEqualToArray:@[[self error:200 testError:[RxTestError testError]]]], @"");

    XCTAssertTrue(xs.subscriptions.count == 0);
}

- (void)testMulticast_SubjectSelectorThrowsException {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:210 element:@1],
            [self next:240 element:@2],
            [self completed:300]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs multicast:^id <RxSubjectType> {
            id error = [[NSObject alloc] init];
            [error objectAtIndex:0];
            return [RxPublishSubject create];
        } selector:^RxObservable *(RxObservable *observable) {
            return observable;
        }];
    }];

    XCTAssertTrue(res.events.count == 1);
    RxRecorded<RxEvent *> *type = res.events[0];
    XCTAssertTrue(type.value.error.code == 105);
    XCTAssertTrue(xs.subscriptions.count == 0);
}

#pragma mark - ref count

// TODO implement test mock objects

- (void)testRefCount_DeadlockSimple {
    
}

- (void)testRefCount_DeadlockErrorAfterN {
    
}

- (void)testRefCount_DeadlockErrorImmediatelly {
    
}

- (void)testRefCount_DeadlockEmpty {
    
}

- (void)testRefCount_ConnectsOnFirst {
    
}

- (void)testRefCount_NotConnected {
    
}

- (void)testRefCount_Error {
    RxObservable<NSNumber *> *xs = [RxObservable error:[RxTestError testError]];

    RxObservable *res = [[xs publish] refCount];
    [res subscribeOn:^(RxEvent *event) {
        switch (event.type) {
            case RxEventTypeNext:
                XCTAssertTrue(NO);
                break;
            case RxEventTypeError:
                XCTAssertTrue([event.error isEqual:[RxTestError testError]]);
                break;
            case RxEventTypeCompleted:
                XCTAssertTrue(NO);
                break;
        }
    }];
    [res subscribeOn:^(RxEvent *event) {
        switch (event.type) {
            case RxEventTypeNext:
                XCTAssertTrue(NO);
                break;
            case RxEventTypeError:
                XCTAssertTrue([event.error isEqual:[RxTestError testError]]);
                break;
            case RxEventTypeCompleted:
                XCTAssertTrue(NO);
                break;
        }
    }];
}

- (void)testRefCount_Publish {
    __block RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:210 element:@1],
            [self next:220 element:@2],
            [self next:230 element:@3],
            [self next:240 element:@4],
            [self next:250 element:@5],
            [self next:260 element:@6],
            [self next:270 element:@7],
            [self next:280 element:@8],
            [self next:290 element:@9],
            [self completed:300]
    ]];

    __block RxObservable *res = [[xs publish] refCount];
    
    __block id <RxDisposable> d1 = nil;
    __block RxTestableObserver<NSNumber *> *o1 = [scheduler createObserver];
    [scheduler scheduleAt:215 action:^{ d1 = [res subscribe:o1]; }];
    [scheduler scheduleAt:235 action:^{ [d1 dispose]; }];

    __block id <RxDisposable> d2 = nil;
    __block __block RxTestableObserver<NSNumber *> *o2 = [scheduler createObserver];
    [scheduler scheduleAt:225 action:^{ d2 = [res subscribe:o2]; }];
    [scheduler scheduleAt:275 action:^{ [d2 dispose]; }];

    __block id <RxDisposable> d3 = nil;
    __block __block RxTestableObserver<NSNumber *> *o3 = [scheduler createObserver];
    [scheduler scheduleAt:255 action:^{ d3 = [res subscribe:o3]; }];
    [scheduler scheduleAt:265 action:^{ [d3 dispose]; }];

    __block id <RxDisposable> d4 = nil;
    __block __block RxTestableObserver<NSNumber *> *o4 = [scheduler createObserver];
    [scheduler scheduleAt:285 action:^{ d4 = [res subscribe:o4]; }];
    [scheduler scheduleAt:320 action:^{ [d4 dispose]; }];

    [scheduler start];

    NSArray *array = @[
            [self next:220 element:@2],
            [self next:230 element:@3],
    ];
    
    XCTAssertTrue([o1.events isEqualToArray:array]);

    NSArray *otherArray = @[
            [self next:230 element:@3],
            [self next:240 element:@4],
            [self next:250 element:@5],
            [self next:260 element:@6],
            [self next:270 element:@7],
    ];
    XCTAssertTrue([o2.events isEqualToArray:otherArray]);

    NSArray *array1 = @[
            [self next:260 element:@6]
    ];
    XCTAssertTrue([o3.events isEqualToArray:array1]);

    NSArray *array2 = @[
            [self next:290 element:@9],
            [self completed:300]
    ];
    XCTAssertTrue([o4.events isEqualToArray:array2]);


    NSArray *array3 = @[
            [[RxSubscription alloc] initWithSubscribe:215 unsubscribe:275],
            [[RxSubscription alloc] initWithSubscribe:285 unsubscribe:300],
    ];
    XCTAssertTrue([xs.subscriptions isEqualToArray:array3]);
}

#pragma mark - replay

- (void)testReplayCount_Basic {
    __block RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    
    __block RxTestableObservable<NSNumber *> *xs = [scheduler createHotObservable:@[
            [self next:110 element:@7],
            [self next:220 element:@3],
            [self next:280 element:@4],
            [self next:290 element:@1],
            [self next:340 element:@8],
            [self next:360 element:@5],
            [self next:370 element:@6],
            [self next:390 element:@7],
            [self next:410 element:@13],
            [self next:430 element:@2],
            [self next:450 element:@9],
            [self next:520 element:@11],
            [self next:560 element:@20],
            [self error:600 testError:[RxTestError testError]]
    ]];
    
    __block RxConnectableObservable *ys = nil;
    __block id <RxDisposable> subscription = nil;
    __block id <RxDisposable> connection = nil;
    __block RxTestableObserver<NSNumber *> *res = [scheduler createObserver];

    [scheduler scheduleAt:RxTestSchedulerDefaultCreated action:^{ys = [xs replay:3];}];
    [scheduler scheduleAt:450 action:^{subscription = [ys subscribe:res];}];
    [scheduler scheduleAt:RxTestSchedulerDefaultDisposed action:^{[subscription dispose];}];

    [scheduler scheduleAt:300 action:^{connection = [ys connect];}];
    [scheduler scheduleAt:400 action:^{[connection dispose];}];

    [scheduler scheduleAt:500 action:^{connection = [ys connect];}];
    [scheduler scheduleAt:550 action:^{[connection dispose];}];

    [scheduler scheduleAt:650 action:^{connection = [ys connect];}];
    [scheduler scheduleAt:800 action:^{[connection dispose];}];

    [scheduler start];

    NSArray *array = @[
            [self next:450 element:@5],
            [self next:450 element:@6],
            [self next:450 element:@7],
            [self next:520 element:@11],
            
    ];
    XCTAssertTrue([res.events isEqualToArray:array]);

    NSArray *otherArray = @[
            [[RxSubscription alloc] initWithSubscribe:300 unsubscribe:400],
            [[RxSubscription alloc] initWithSubscribe:500 unsubscribe:550],
            [[RxSubscription alloc] initWithSubscribe:650 unsubscribe:800],
    ];
    XCTAssertTrue([xs.subscriptions isEqualToArray:otherArray]);
}

- (void)testReplayCount_Error {
    __block RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block RxTestableObservable<NSNumber *> *xs = [scheduler createHotObservable:@[
            [self next:110 element:@7],
            [self next:220 element:@3],
            [self next:280 element:@4],
            [self next:290 element:@1],
            [self next:340 element:@8],
            [self next:360 element:@5],
            [self next:370 element:@6],
            [self next:390 element:@7],
            [self next:410 element:@13],
            [self next:430 element:@2],
            [self next:450 element:@9],
            [self next:520 element:@11],
            [self next:560 element:@20],
            [self error:600 testError:[RxTestError testError]]
    ]];

    __block RxConnectableObservable *ys = nil;
    __block id <RxDisposable> subscription = nil;
    __block id <RxDisposable> connection = nil;
    __block RxTestableObserver<NSNumber *> *res = [scheduler createObserver];

    [scheduler scheduleAt:RxTestSchedulerDefaultCreated action:^{ys = [xs replay:3];}];
    [scheduler scheduleAt:450 action:^{subscription = [ys subscribe:res];}];
    [scheduler scheduleAt:RxTestSchedulerDefaultDisposed action:^{[subscription dispose];}];

    [scheduler scheduleAt:300 action:^{connection = [ys connect];}];
    [scheduler scheduleAt:400 action:^{[connection dispose];}];

    [scheduler scheduleAt:500 action:^{connection = [ys connect];}];
    [scheduler scheduleAt:800 action:^{[connection dispose];}];

    [scheduler start];

    NSArray *array = @[
            [self next:450 element:@5],
            [self next:450 element:@6],
            [self next:450 element:@7],
            [self next:520 element:@11],
            [self next:560 element:@20],
            [self error:600 testError:[RxTestError testError]]
    ];

    XCTAssertTrue([res.events isEqualToArray:array]);

    NSArray *otherArray = @[
            [[RxSubscription alloc] initWithSubscribe:300 unsubscribe:400],
            [[RxSubscription alloc] initWithSubscribe:500 unsubscribe:600],
    ];
    XCTAssertTrue([xs.subscriptions isEqualToArray:otherArray]);
}

- (void)testReplayCount_Complete {
    __block RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block RxTestableObservable<NSNumber *> *xs = [scheduler createHotObservable:@[
            [self next:110 element:@7],
            [self next:220 element:@3],
            [self next:280 element:@4],
            [self next:290 element:@1],
            [self next:340 element:@8],
            [self next:360 element:@5],
            [self next:370 element:@6],
            [self next:390 element:@7],
            [self next:410 element:@13],
            [self next:430 element:@2],
            [self next:450 element:@9],
            [self next:520 element:@11],
            [self next:560 element:@20],
            [self completed:600]
    ]];

    __block RxConnectableObservable *ys = nil;
    __block id <RxDisposable> subscription = nil;
    __block id <RxDisposable> connection = nil;
    __block RxTestableObserver<NSNumber *> *res = [scheduler createObserver];

    [scheduler scheduleAt:RxTestSchedulerDefaultCreated action:^{ys = [xs replay:3];}];
    [scheduler scheduleAt:450 action:^{subscription = [ys subscribe:res];}];
    [scheduler scheduleAt:RxTestSchedulerDefaultDisposed action:^{[subscription dispose];}];

    [scheduler scheduleAt:300 action:^{connection = [ys connect];}];
    [scheduler scheduleAt:400 action:^{[connection dispose];}];

    [scheduler scheduleAt:500 action:^{connection = [ys connect];}];
    [scheduler scheduleAt:800 action:^{[connection dispose];}];

    [scheduler start];

    NSArray *array = @[
            [self next:450 element:@5],
            [self next:450 element:@6],
            [self next:450 element:@7],
            [self next:520 element:@11],
            [self next:560 element:@20],
            [self completed:600]
    ];

    XCTAssertTrue([res.events isEqualToArray:array]);

    NSArray *otherArray = @[
            [[RxSubscription alloc] initWithSubscribe:300 unsubscribe:400],
            [[RxSubscription alloc] initWithSubscribe:500 unsubscribe:600],
    ];
    XCTAssertTrue([xs.subscriptions isEqualToArray:otherArray]);
}

- (void)testReplayCount_Dispose {
    __block RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block RxTestableObservable<NSNumber *> *xs = [scheduler createHotObservable:@[
            [self next:110 element:@7],
            [self next:220 element:@3],
            [self next:280 element:@4],
            [self next:290 element:@1],
            [self next:340 element:@8],
            [self next:360 element:@5],
            [self next:370 element:@6],
            [self next:390 element:@7],
            [self next:410 element:@13],
            [self next:430 element:@2],
            [self next:450 element:@9],
            [self next:520 element:@11],
            [self next:560 element:@20],
            [self completed:600]
    ]];

    __block RxConnectableObservable *ys = nil;
    __block id <RxDisposable> subscription = nil;
    __block id <RxDisposable> connection = nil;
    __block RxTestableObserver<NSNumber *> *res = [scheduler createObserver];

    [scheduler scheduleAt:RxTestSchedulerDefaultCreated action:^{ys = [xs replay:3];}];
    [scheduler scheduleAt:450 action:^{subscription = [ys subscribe:res];}];
    [scheduler scheduleAt:475 action:^{[subscription dispose];}];

    [scheduler scheduleAt:300 action:^{connection = [ys connect];}];
    [scheduler scheduleAt:400 action:^{[connection dispose];}];

    [scheduler scheduleAt:500 action:^{connection = [ys connect];}];
    [scheduler scheduleAt:550 action:^{[connection dispose];}];

    [scheduler scheduleAt:650 action:^{connection = [ys connect];}];
    [scheduler scheduleAt:800 action:^{[connection dispose];}];

    [scheduler start];

    NSArray *array = @[
            [self next:450 element:@5],
            [self next:450 element:@6],
            [self next:450 element:@7],
    ];

    XCTAssertTrue([res.events isEqualToArray:array]);

    NSArray *otherArray = @[
            [[RxSubscription alloc] initWithSubscribe:300 unsubscribe:400],
            [[RxSubscription alloc] initWithSubscribe:500 unsubscribe:550],
            [[RxSubscription alloc] initWithSubscribe:650 unsubscribe:800],
    ];
    XCTAssertTrue([xs.subscriptions isEqualToArray:otherArray]);
}

- (void)testReplayOneCount_Basic {
    __block RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block RxTestableObservable<NSNumber *> *xs = [scheduler createHotObservable:@[
            [self next:110 element:@7],
            [self next:220 element:@3],
            [self next:280 element:@4],
            [self next:290 element:@1],
            [self next:340 element:@8],
            [self next:360 element:@5],
            [self next:370 element:@6],
            [self next:390 element:@7],
            [self next:410 element:@13],
            [self next:430 element:@2],
            [self next:450 element:@9],
            [self next:520 element:@11],
            [self next:560 element:@20],
            [self error:600 testError:[RxTestError testError]]
    ]];

    __block RxConnectableObservable *ys = nil;
    __block id <RxDisposable> subscription = nil;
    __block id <RxDisposable> connection = nil;
    __block RxTestableObserver<NSNumber *> *res = [scheduler createObserver];

    [scheduler scheduleAt:RxTestSchedulerDefaultCreated action:^{ ys = [xs replay:1]; }];
    [scheduler scheduleAt:450 action:^{ subscription = [ys subscribe:res]; }];
    [scheduler scheduleAt:RxTestSchedulerDefaultDisposed action:^{ [subscription dispose]; }];

    [scheduler scheduleAt:300 action:^{ connection = [ys connect]; }];
    [scheduler scheduleAt:400 action:^{ [connection dispose]; }];

    [scheduler scheduleAt:500 action:^{ connection = [ys connect]; }];
    [scheduler scheduleAt:550 action:^{ [connection dispose]; }];

    [scheduler scheduleAt:650 action:^{ connection = [ys connect]; }];
    [scheduler scheduleAt:800 action:^{ [connection dispose]; }];

    [scheduler start];

    NSArray *array = @[
            [self next:450 element:@7],
            [self next:520 element:@11],
    ];

    XCTAssertTrue([res.events isEqualToArray:array]);

    NSArray *otherArray = @[
            [[RxSubscription alloc] initWithSubscribe:300 unsubscribe:400],
            [[RxSubscription alloc] initWithSubscribe:500 unsubscribe:550],
            [[RxSubscription alloc] initWithSubscribe:650 unsubscribe:800],
    ];
    XCTAssertTrue([xs.subscriptions isEqualToArray:otherArray]);
}

- (void)testReplayOneCount_Error {
    __block RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block RxTestableObservable<NSNumber *> *xs = [scheduler createHotObservable:@[
            [self next:110 element:@7],
            [self next:220 element:@3],
            [self next:280 element:@4],
            [self next:290 element:@1],
            [self next:340 element:@8],
            [self next:360 element:@5],
            [self next:370 element:@6],
            [self next:390 element:@7],
            [self next:410 element:@13],
            [self next:430 element:@2],
            [self next:450 element:@9],
            [self next:520 element:@11],
            [self next:560 element:@20],
            [self error:600 testError:[RxTestError testError]]
    ]];

    __block RxConnectableObservable *ys = nil;
    __block id <RxDisposable> subscription = nil;
    __block id <RxDisposable> connection = nil;
    __block RxTestableObserver<NSNumber *> *res = [scheduler createObserver];

    [scheduler scheduleAt:RxTestSchedulerDefaultCreated action:^{ ys = [xs replay:1]; }];
    [scheduler scheduleAt:450 action:^{ subscription = [ys subscribe:res]; }];
    [scheduler scheduleAt:RxTestSchedulerDefaultDisposed action:^{ [subscription dispose]; }];

    [scheduler scheduleAt:300 action:^{ connection = [ys connect]; }];
    [scheduler scheduleAt:400 action:^{ [connection dispose]; }];

    [scheduler scheduleAt:500 action:^{ connection = [ys connect]; }];
    [scheduler scheduleAt:800 action:^{ [connection dispose]; }];

    [scheduler start];

    NSArray *array = @[
            [self next:450 element:@7],
            [self next:520 element:@11],
            [self next:560 element:@20],
            [self error:600 testError:[RxTestError testError]],
    ];

    XCTAssertTrue([res.events isEqualToArray:array]);

    NSArray *otherArray = @[
            [[RxSubscription alloc] initWithSubscribe:300 unsubscribe:400],
            [[RxSubscription alloc] initWithSubscribe:500 unsubscribe:600],
    ];
    XCTAssertTrue([xs.subscriptions isEqualToArray:otherArray]);
}

- (void)testReplayOneCount_Complete {
    __block RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block RxTestableObservable<NSNumber *> *xs = [scheduler createHotObservable:@[
            [self next:110 element:@7],
            [self next:220 element:@3],
            [self next:280 element:@4],
            [self next:290 element:@1],
            [self next:340 element:@8],
            [self next:360 element:@5],
            [self next:370 element:@6],
            [self next:390 element:@7],
            [self next:410 element:@13],
            [self next:430 element:@2],
            [self next:450 element:@9],
            [self next:520 element:@11],
            [self next:560 element:@20],
            [self completed:600]
    ]];

    __block RxConnectableObservable *ys = nil;
    __block id <RxDisposable> subscription = nil;
    __block id <RxDisposable> connection = nil;
    __block RxTestableObserver<NSNumber *> *res = [scheduler createObserver];

    [scheduler scheduleAt:RxTestSchedulerDefaultCreated action:^{ ys = [xs replay:1]; }];
    [scheduler scheduleAt:450 action:^{ subscription = [ys subscribe:res]; }];
    [scheduler scheduleAt:RxTestSchedulerDefaultDisposed action:^{ [subscription dispose]; }];

    [scheduler scheduleAt:300 action:^{ connection = [ys connect]; }];
    [scheduler scheduleAt:400 action:^{ [connection dispose]; }];

    [scheduler scheduleAt:500 action:^{ connection = [ys connect]; }];
    [scheduler scheduleAt:800 action:^{ [connection dispose]; }];

    [scheduler start];

    NSArray *array = @[
            [self next:450 element:@7],
            [self next:520 element:@11],
            [self next:560 element:@20],
            [self completed:600],
    ];

    XCTAssertTrue([res.events isEqualToArray:array]);

    NSArray *otherArray = @[
            [[RxSubscription alloc] initWithSubscribe:300 unsubscribe:400],
            [[RxSubscription alloc] initWithSubscribe:500 unsubscribe:600],
    ];
    XCTAssertTrue([xs.subscriptions isEqualToArray:otherArray]);
}

- (void)testReplayOneCount_Dispose {
    __block RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block RxTestableObservable<NSNumber *> *xs = [scheduler createHotObservable:@[
            [self next:110 element:@7],
            [self next:220 element:@3],
            [self next:280 element:@4],
            [self next:290 element:@1],
            [self next:340 element:@8],
            [self next:360 element:@5],
            [self next:370 element:@6],
            [self next:390 element:@7],
            [self next:410 element:@13],
            [self next:430 element:@2],
            [self next:450 element:@9],
            [self next:520 element:@11],
            [self next:560 element:@20],
            [self completed:600]
    ]];

    __block RxConnectableObservable *ys = nil;
    __block id <RxDisposable> subscription = nil;
    __block id <RxDisposable> connection = nil;
    __block RxTestableObserver<NSNumber *> *res = [scheduler createObserver];

    [scheduler scheduleAt:RxTestSchedulerDefaultCreated action:^{ ys = [xs replay:1]; }];
    [scheduler scheduleAt:450 action:^{ subscription = [ys subscribe:res]; }];
    [scheduler scheduleAt:475 action:^{ [subscription dispose]; }];

    [scheduler scheduleAt:300 action:^{ connection = [ys connect]; }];
    [scheduler scheduleAt:400 action:^{ [connection dispose]; }];

    [scheduler scheduleAt:500 action:^{ connection = [ys connect]; }];
    [scheduler scheduleAt:550 action:^{ [connection dispose]; }];

    [scheduler scheduleAt:650 action:^{ connection = [ys connect]; }];
    [scheduler scheduleAt:800 action:^{ [connection dispose]; }];

    [scheduler start];

    NSArray *array = @[
            [self next:450 element:@7],
    ];

    XCTAssertTrue([res.events isEqualToArray:array]);

    NSArray *otherArray = @[
            [[RxSubscription alloc] initWithSubscribe:300 unsubscribe:400],
            [[RxSubscription alloc] initWithSubscribe:500 unsubscribe:550],
            [[RxSubscription alloc] initWithSubscribe:650 unsubscribe:800],
    ];
    XCTAssertTrue([xs.subscriptions isEqualToArray:otherArray]);
}

- (void)testReplayAll_Basic {
    __block RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block RxTestableObservable<NSNumber *> *xs = [scheduler createHotObservable:@[
            [self next:110 element:@7],
            [self next:220 element:@3],
            [self next:280 element:@4],
            [self next:290 element:@1],
            [self next:340 element:@8],
            [self next:360 element:@5],
            [self next:370 element:@6],
            [self next:390 element:@7],
            [self next:410 element:@13],
            [self next:430 element:@2],
            [self next:450 element:@9],
            [self next:520 element:@11],
            [self next:560 element:@20],
            [self error:600 testError:[RxTestError testError]]
    ]];

    __block RxConnectableObservable *ys = nil;
    __block id <RxDisposable> subscription = nil;
    __block id <RxDisposable> connection = nil;
    __block RxTestableObserver<NSNumber *> *res = [scheduler createObserver];

    [scheduler scheduleAt:RxTestSchedulerDefaultCreated action:^{ ys = [xs replayAll]; }];
    [scheduler scheduleAt:450 action:^{ subscription = [ys subscribe:res]; }];
    [scheduler scheduleAt:RxTestSchedulerDefaultDisposed action:^{ [subscription dispose]; }];

    [scheduler scheduleAt:200 action:^{ connection = [ys connect]; }];
    [scheduler scheduleAt:400 action:^{ [connection dispose]; }];

    [scheduler scheduleAt:500 action:^{ connection = [ys connect]; }];
    [scheduler scheduleAt:550 action:^{ [connection dispose]; }];

    [scheduler scheduleAt:650 action:^{ connection = [ys connect]; }];
    [scheduler scheduleAt:800 action:^{ [connection dispose]; }];

    [scheduler start];

    NSArray *array = @[
            [self next:450 element:@3],
            [self next:450 element:@4],
            [self next:450 element:@1],
            [self next:450 element:@8],
            [self next:450 element:@5],
            [self next:450 element:@6],
            [self next:450 element:@7],
            [self next:520 element:@11],
    ];

    XCTAssertTrue([res.events isEqualToArray:array]);

    NSArray *otherArray = @[
            [[RxSubscription alloc] initWithSubscribe:200 unsubscribe:400],
            [[RxSubscription alloc] initWithSubscribe:500 unsubscribe:550],
            [[RxSubscription alloc] initWithSubscribe:650 unsubscribe:800],
    ];
    XCTAssertTrue([xs.subscriptions isEqualToArray:otherArray]);
}

- (void)testReplayAll_Error {
    __block RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block RxTestableObservable<NSNumber *> *xs = [scheduler createHotObservable:@[
            [self next:110 element:@7],
            [self next:220 element:@3],
            [self next:280 element:@4],
            [self next:290 element:@1],
            [self next:340 element:@8],
            [self next:360 element:@5],
            [self next:370 element:@6],
            [self next:390 element:@7],
            [self next:410 element:@13],
            [self next:430 element:@2],
            [self next:450 element:@9],
            [self next:520 element:@11],
            [self next:560 element:@20],
            [self error:600 testError:[RxTestError testError]]
    ]];

    __block RxConnectableObservable *ys = nil;
    __block id <RxDisposable> subscription = nil;
    __block id <RxDisposable> connection = nil;
    __block RxTestableObserver<NSNumber *> *res = [scheduler createObserver];

    [scheduler scheduleAt:RxTestSchedulerDefaultCreated action:^{ ys = [xs replayAll]; }];
    [scheduler scheduleAt:450 action:^{ subscription = [ys subscribe:res]; }];
    [scheduler scheduleAt:RxTestSchedulerDefaultDisposed action:^{ [subscription dispose]; }];

    [scheduler scheduleAt:300 action:^{ connection = [ys connect]; }];
    [scheduler scheduleAt:400 action:^{ [connection dispose]; }];

    [scheduler scheduleAt:500 action:^{ connection = [ys connect]; }];
    [scheduler scheduleAt:800 action:^{ [connection dispose]; }];

    [scheduler start];

    NSArray *array = @[
            [self next:450 element:@8],
            [self next:450 element:@5],
            [self next:450 element:@6],
            [self next:450 element:@7],
            [self next:520 element:@11],
            [self next:560 element:@20],
            [self error:600 testError:[RxTestError testError]]
    ];

    XCTAssertTrue([res.events isEqualToArray:array]);

    NSArray *otherArray = @[
            [[RxSubscription alloc] initWithSubscribe:300 unsubscribe:400],
            [[RxSubscription alloc] initWithSubscribe:500 unsubscribe:600],
    ];
    XCTAssertTrue([xs.subscriptions isEqualToArray:otherArray]);
}

- (void)testReplayAll_Complete {
    __block RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block RxTestableObservable<NSNumber *> *xs = [scheduler createHotObservable:@[
            [self next:110 element:@7],
            [self next:220 element:@3],
            [self next:280 element:@4],
            [self next:290 element:@1],
            [self next:340 element:@8],
            [self next:360 element:@5],
            [self next:370 element:@6],
            [self next:390 element:@7],
            [self next:410 element:@13],
            [self next:430 element:@2],
            [self next:450 element:@9],
            [self next:520 element:@11],
            [self next:560 element:@20],
            [self completed:600]
    ]];

    __block RxConnectableObservable *ys = nil;
    __block id <RxDisposable> subscription = nil;
    __block id <RxDisposable> connection = nil;
    __block RxTestableObserver<NSNumber *> *res = [scheduler createObserver];

    [scheduler scheduleAt:RxTestSchedulerDefaultCreated action:^{ ys = [xs replayAll]; }];
    [scheduler scheduleAt:450 action:^{ subscription = [ys subscribe:res]; }];
    [scheduler scheduleAt:RxTestSchedulerDefaultDisposed action:^{ [subscription dispose]; }];

    [scheduler scheduleAt:300 action:^{ connection = [ys connect]; }];
    [scheduler scheduleAt:400 action:^{ [connection dispose]; }];

    [scheduler scheduleAt:500 action:^{ connection = [ys connect]; }];
    [scheduler scheduleAt:800 action:^{ [connection dispose]; }];

    [scheduler start];

    NSArray *array = @[
            [self next:450 element:@8],
            [self next:450 element:@5],
            [self next:450 element:@6],
            [self next:450 element:@7],
            [self next:520 element:@11],
            [self next:560 element:@20],
            [self completed:600]
    ];

    XCTAssertTrue([res.events isEqualToArray:array]);

    NSArray *otherArray = @[
            [[RxSubscription alloc] initWithSubscribe:300 unsubscribe:400],
            [[RxSubscription alloc] initWithSubscribe:500 unsubscribe:600],
    ];
    XCTAssertTrue([xs.subscriptions isEqualToArray:otherArray]);
}

- (void)testReplayAll_Dispose {
    __block RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    __block RxTestableObservable<NSNumber *> *xs = [scheduler createHotObservable:@[
            [self next:110 element:@7],
            [self next:220 element:@3],
            [self next:280 element:@4],
            [self next:290 element:@1],
            [self next:340 element:@8],
            [self next:360 element:@5],
            [self next:370 element:@6],
            [self next:390 element:@7],
            [self next:410 element:@13],
            [self next:430 element:@2],
            [self next:450 element:@9],
            [self next:520 element:@11],
            [self next:560 element:@20],
            [self error:600 testError:[RxTestError testError]]
    ]];

    __block RxConnectableObservable *ys = nil;
    __block id <RxDisposable> subscription = nil;
    __block id <RxDisposable> connection = nil;
    __block RxTestableObserver<NSNumber *> *res = [scheduler createObserver];

    [scheduler scheduleAt:RxTestSchedulerDefaultCreated action:^{ ys = [xs replayAll]; }];
    [scheduler scheduleAt:450 action:^{ subscription = [ys subscribe:res]; }];
    [scheduler scheduleAt:475 action:^{ [subscription dispose]; }];

    [scheduler scheduleAt:250 action:^{ connection = [ys connect]; }];
    [scheduler scheduleAt:400 action:^{ [connection dispose]; }];

    [scheduler scheduleAt:500 action:^{ connection = [ys connect]; }];
    [scheduler scheduleAt:550 action:^{ [connection dispose]; }];

    [scheduler scheduleAt:650 action:^{ connection = [ys connect]; }];
    [scheduler scheduleAt:800 action:^{ [connection dispose]; }];

    [scheduler start];

    NSArray *array = @[
            [self next:450 element:@4],
            [self next:450 element:@1],
            [self next:450 element:@8],
            [self next:450 element:@5],
            [self next:450 element:@6],
            [self next:450 element:@7],
    ];

    XCTAssertTrue([res.events isEqualToArray:array]);

    NSArray *otherArray = @[
            [[RxSubscription alloc] initWithSubscribe:250 unsubscribe:400],
            [[RxSubscription alloc] initWithSubscribe:500 unsubscribe:550],
            [[RxSubscription alloc] initWithSubscribe:650 unsubscribe:800],
    ];
    XCTAssertTrue([xs.subscriptions isEqualToArray:otherArray]);
}

#pragma mark - shareReplay(1)

- (void)_testIdenticalBehaviorOfShareReplayOptimizedAndComposed:(void(^)(RxObservable<NSNumber *> *(^)(RxObservable<NSNumber *> *)))action {
    action(^RxObservable<NSNumber *> *(RxObservable<NSNumber *> *observable) {
        return [observable shareReplay:1];
    });
    action(^RxObservable<NSNumber *> *(RxObservable<NSNumber *> *observable) {
        return [[observable replay:1] refCount];
    });
}

- (void)testShareReplay_DeadlockImmediatelly {
    [self _testIdenticalBehaviorOfShareReplayOptimizedAndComposed:^(RxObservable<NSNumber *> *(^transform)(RxObservable<NSNumber *> *)) {
        __block int nEvents = 0;

        RxObservable<NSNumber *> *observable = transform([RxObservable of:@[@0, @1, @2]]);

        [observable subscribeNext:^(NSNumber *n) {
            nEvents++;
        }];
        XCTAssertTrue(nEvents == 3);
    }];
}

- (void)testShareReplay_DeadlockEmpty {
    [self _testIdenticalBehaviorOfShareReplayOptimizedAndComposed:^(RxObservable<NSNumber *> *(^transform)(RxObservable<NSNumber *> *)) {
        __block int nextEventsCount = 0;
        __block int completedEventsCount = 0;

        RxObservable<NSNumber *> *observable = transform([RxObservable empty]);

        [observable subscribeOnNext:^(NSNumber *n) {
            nextEventsCount++;
        } onError:nil onCompleted:^{
            completedEventsCount++;
        }];


        XCTAssertTrue(nextEventsCount == 0);
        XCTAssertTrue(completedEventsCount == 1);
    }];
}

- (void)testShareReplay_DeadlockError {
    [self _testIdenticalBehaviorOfShareReplayOptimizedAndComposed:^(RxObservable<NSNumber *> *(^transform)(RxObservable<NSNumber *> *)) {
        __block int eEvents = 0;
        __block NSError *_error = nil;

        RxObservable<NSNumber *> *observable = transform([RxObservable error:[RxTestError testError]]);

        [observable subscribeError:^(NSError *error) {
            eEvents++;
            _error = error;
        }];

        XCTAssertTrue(eEvents == 1);
        XCTAssertTrue(_error == [RxTestError testError]);
    }];
}

- (void)testShareReplay1_DeadlockErrorAfterN {
    [self _testIdenticalBehaviorOfShareReplayOptimizedAndComposed:^(RxObservable<NSNumber *> *(^transform)(RxObservable<NSNumber *> *)) {
        __block int eEvents = 0;
        __block NSError *_error = nil;

        RxObservable<NSNumber *> *observable = transform(
                @[[RxObservable of:@[@1, @2, @3]],
                  [RxObservable error:[RxTestError testError]]
                ].concat);

        [observable subscribeError:^(NSError *error) {
            eEvents++;
            _error = error;
        }];

        XCTAssertTrue(eEvents == 1);
        XCTAssertTrue(_error == [RxTestError testError]);
    }];
}

@end

#pragma clang diagnostic pop