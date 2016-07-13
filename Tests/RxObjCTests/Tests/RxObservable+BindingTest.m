//
//  RxObservableBindingTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"
#import "RxObjC.h"
#import "RxObservable+Binding.h"
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
#import "RxMySubject.h"
#import "RxTestConnectableObservable.h"
#import "RxAnonymousDisposable.h"

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCDFAInspection"
@interface RxObservableBindingTest : RxTest

@end

@implementation RxObservableBindingTest
@end

@implementation RxObservableBindingTest (Mutlicast)

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

- (void)testMulticast_SubjectSelectorThrows {
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

- (void)testMulticast_SelectorThrows {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:210 element:@1],
            [self next:240 element:@2],
            [self completed:300]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs multicast:^id <RxSubjectType> {
            return [RxPublishSubject create];
        } selector:^RxObservable *(RxObservable *observable) {
            @throw [RxTestError testError];
            return observable;
        }];
    }];

    XCTAssertTrue([res.events isEqualToArray:@[[self error:200 testError:[RxTestError testError]]]], @"");
    XCTAssertTrue(xs.subscriptions.count == 0);
}

@end

@implementation RxObservableBindingTest (RefCount)

- (void)testRefCount_DeadlockSimple {
    RxMySubject<NSNumber *> *subject = [RxMySubject create];
    
    __block int nEvents = 0;

    RxTestConnectableObservable<RxMySubject<NSNumber *> *> *observable = [[RxTestConnectableObservable alloc] initWithObservable:[RxObservable of:@[@0, @1, @2]] subject:subject];

    id <RxDisposable> d = [observable subscribeNext:^(NSNumber *n) {
        nEvents++;
    }];

    [[observable connect] dispose];
    
    XCTAssertTrue(nEvents == 3);
    
    [d dispose];
}

- (void)testRefCount_DeadlockErrorAfterN {
    RxMySubject<NSNumber *> *subject = [RxMySubject create];

    __block int nEvents = 0;

    RxTestConnectableObservable *observable = 
            [[RxTestConnectableObservable alloc] initWithObservable:[@[[RxObservable of:@[@0, @1, @2]], [RxObservable error:[RxTestError testError]]] concat]
                                                            subject:subject];

    id <RxDisposable> d = [observable subscribeError:^(NSError *error) {
        nEvents++;
    }];

    [[observable connect] dispose];

    XCTAssertTrue(nEvents == 1);

    [d dispose];
}

- (void)testRefCount_DeadlockErrorImmediatelly {
    RxMySubject<NSNumber *> *subject = [RxMySubject create];

    __block int nEvents = 0;

    RxTestConnectableObservable *observable =
            [[RxTestConnectableObservable alloc] initWithObservable:[RxObservable error:[RxTestError testError]]
                                                            subject:subject];

    id <RxDisposable> d = [observable subscribeError:^(NSError *error) {
        nEvents++;
    }];

    [[observable connect] dispose];

    XCTAssertTrue(nEvents == 1);

    [d dispose];
}

- (void)testRefCount_DeadlockEmpty {
    RxMySubject<NSNumber *> *subject = [RxMySubject create];

    __block int nEvents = 0;

    RxTestConnectableObservable *observable = [[RxTestConnectableObservable alloc] initWithObservable:[RxObservable empty]
                                                                                              subject:subject];

    id <RxDisposable> d = [observable subscribeCompleted:^{
        nEvents++;
    }];

    [[observable connect] dispose];

    XCTAssertTrue(nEvents == 1);

    [d dispose];
}

- (void)testRefCount_ConnectsOnFirst {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:210 element:@1],
            [self next:220 element:@2],
            [self next:230 element:@3],
            [self next:240 element:@4],
            [self completed:250]
    ]];

    RxMySubject<NSNumber *> *subject = [RxMySubject create];

    RxTestConnectableObservable *conn = [[RxTestConnectableObservable alloc] initWithObservable:[xs asObservable] subject:subject];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [conn refCount];
    }];

    NSArray *array = @[
            [self next:210 element:@1],
            [self next:220 element:@2],
            [self next:230 element:@3],
            [self next:240 element:@4],
            [self completed:250]
    ];
    
    XCTAssertTrue([res.events isEqualToArray:array]);
    
    XCTAssertTrue([subject disposed]);
}

- (void)testRefCount_NotConnected {
    RxTestScheduler *__unused _ = [[RxTestScheduler alloc] initWithInitialClock:0];
    
    __block BOOL disconnected = NO;
    __block int count = 0;

    RxObservable<NSNumber *> *xs = [RxObservable deferred:^RxObservable * {
        count++;
        return [RxObservable create:^id <RxDisposable>(RxAnyObserver *obs) {
            return [RxAnonymousDisposable create:^{
                disconnected = YES;
            }];
        }];
    }];

    RxMySubject<NSNumber *> *subject = [RxMySubject create];

    RxTestConnectableObservable *conn = [[RxTestConnectableObservable alloc] initWithObservable:xs subject:subject];
    RxObservable *refd = [conn refCount];

    id <RxDisposable> dis1 = [refd subscribeWith:^(RxEvent *__unused event){}];
    XCTAssertEqual(count, 1);
    XCTAssertEqual(subject.subscribeCount, 1);
    XCTAssertFalse(disconnected);

    id <RxDisposable> dis2 = [refd subscribeWith:^(RxEvent *__unused event){}];
    XCTAssertEqual(count, 1);
    XCTAssertEqual(subject.subscribeCount, 2);
    XCTAssertFalse(disconnected);

    [dis1 dispose];
    XCTAssertFalse(disconnected);
    [dis2 dispose];
    XCTAssertTrue(disconnected);
    disconnected = NO;

    id <RxDisposable> dis3 = [refd subscribeWith:^(RxEvent *__unused event){}];
    XCTAssertEqual(count, 2);
    XCTAssertEqual(subject.subscribeCount, 3);
    XCTAssertFalse(disconnected);

    [dis3 dispose];
    XCTAssertTrue(disconnected);
}

- (void)testRefCount_Error {
    RxObservable<NSNumber *> *xs = [RxObservable error:[RxTestError testError]];

    RxObservable *res = [[xs publish] refCount];
    [res subscribeWith:^(RxEvent *event) {
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
    [res subscribeWith:^(RxEvent *event) {
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

@end

@implementation RxObservableBindingTest (Replay)

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

@end

@implementation RxObservableBindingTest (ShareReplay1)

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

- (void)testShareReplay1_Basic {
    [self _testIdenticalBehaviorOfShareReplayOptimizedAndComposed:^(RxObservable<NSNumber *> *(^transform)(RxObservable<NSNumber *> *)) {
        RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

        RxTestableObservable *xs = [scheduler createHotObservable:@[
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
        
        __block RxObservable<NSNumber *> *ys = nil;
        __block id<RxDisposable> subscription1 = nil;
        __block id<RxDisposable> subscription2 = nil;
        
        __block RxTestableObserver<NSNumber *> *res1 = [scheduler createObserver];
        __block RxTestableObserver<NSNumber *> *res2 = [scheduler createObserver];

        [scheduler scheduleAt:RxTestSchedulerDefaultCreated action:^{ ys = transform([xs asObservable]); }];
        
        [scheduler scheduleAt:335 action:^{ subscription1 = [ys subscribe:res1]; }];
        [scheduler scheduleAt:400 action:^{ [subscription1 dispose]; }];
        
        [scheduler scheduleAt:355 action:^{ subscription2 = [ys subscribe:res2]; }];
        [scheduler scheduleAt:415 action:^{ [subscription2 dispose]; }];

        [scheduler scheduleAt:440 action:^{ subscription1 = [ys subscribe:res1]; }];
        [scheduler scheduleAt:455 action:^{ [subscription1 dispose]; }];
        
        [scheduler start];

        NSArray *array = @[
                    /// 1rt batch
                    [self next:340 element:@8],
                    [self next:360 element:@5],
                    [self next:370 element:@6],
                    [self next:390 element:@7],

                    /// 2nd batch
                    [self next:440 element:@13],
                    [self next:450 element:@9],
            ];
        XCTAssertTrue([res1.events isEqualToArray:array]);

        NSArray *otherArray = @[
                    [self next:355 element:@8],
                    [self next:360 element:@5],
                    [self next:370 element:@6],
                    [self next:390 element:@7],
                    [self next:410 element:@13],
            ];
        XCTAssertTrue([res2.events isEqualToArray:otherArray]);


        NSArray *array1 = @[
                    [[RxSubscription alloc] initWithSubscribe:335 unsubscribe:415],
                    [[RxSubscription alloc] initWithSubscribe:440 unsubscribe:455],
            ];
        XCTAssertTrue([xs.subscriptions isEqualToArray:array1]);
    }];
}

- (void)testShareReplay1_Error {
    [self _testIdenticalBehaviorOfShareReplayOptimizedAndComposed:^(RxObservable<NSNumber *> *(^transform)(RxObservable<NSNumber *> *)) {
        RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

        RxTestableObservable *xs = [scheduler createHotObservable:@[
                    [self next:110 element:@7],
                    [self next:220 element:@3],
                    [self next:280 element:@4],
                    [self next:290 element:@1],
                    [self next:340 element:@8],
                    [self next:360 element:@5],
                    [self error:365 testError:[RxTestError testError]],
                    [self next:370 element:@6],
                    [self next:390 element:@7],
                    [self next:410 element:@13],
                    [self next:430 element:@2],
                    [self next:450 element:@9],
                    [self next:520 element:@11],
                    [self next:560 element:@20],
            ]];

        __block RxObservable<NSNumber *> *ys = nil;
        __block id<RxDisposable> subscription1 = nil;
        __block id<RxDisposable> subscription2 = nil;

        __block RxTestableObserver<NSNumber *> *res1 = [scheduler createObserver];
        __block RxTestableObserver<NSNumber *> *res2 = [scheduler createObserver];

        [scheduler scheduleAt:RxTestSchedulerDefaultCreated action:^{ ys = transform([xs asObservable]); }];

        [scheduler scheduleAt:335 action:^{ subscription1 = [ys subscribe:res1]; }];
        [scheduler scheduleAt:400 action:^{ [subscription1 dispose]; }];

        [scheduler scheduleAt:355 action:^{ subscription2 = [ys subscribe:res2]; }];
        [scheduler scheduleAt:415 action:^{ [subscription2 dispose]; }];

        [scheduler scheduleAt:440 action:^{ subscription1 = [ys subscribe:res1]; }];
        [scheduler scheduleAt:455 action:^{ [subscription1 dispose]; }];

        [scheduler start];

        NSArray *array = @[
                    // 1rt batch
                    [self next:340 element:@8],
                    [self next:360 element:@5],
                    [self error:365 testError:[RxTestError testError]],
                    
                    // 2nd batch
                    [self next:440 element:@5],
                    [self error:440 testError:[RxTestError testError]]
            ];
        XCTAssert([res1.events isEqualToArray:array]);

        NSArray *array1 = @[
                    [self next:355 element:@8],
                    [self next:360 element:@5],
                    [self error:365 testError:[RxTestError testError]]
            ];

        XCTAssert([res2.events isEqualToArray:array1]);

        // unoptimized version of replay subject will make a subscription and kill it immediatelly
        XCTAssert([xs.subscriptions.firstObject isEqual:[RxSubscription createWithSubscribe:335 unsubscribe:365]]);
        XCTAssert(xs.subscriptions.count <= 2);
        XCTAssert(xs.subscriptions.count == 1 || [xs.subscriptions[1] isEqual:[RxSubscription createWithSubscribe:440 unsubscribe:440]]);
    }];
}

- (void)testShareReplay1_Completed {
    [self _testIdenticalBehaviorOfShareReplayOptimizedAndComposed:^(RxObservable<NSNumber *> *(^transform)(RxObservable<NSNumber *> *)) {
        RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

        RxTestableObservable *xs = [scheduler createHotObservable:@[
                [self next:110 element:@7],
                [self next:220 element:@3],
                [self next:280 element:@4],
                [self next:290 element:@1],
                [self next:340 element:@8],
                [self next:360 element:@5],
                [self completed:365],
                [self next:370 element:@6],
                [self next:390 element:@7],
                [self next:410 element:@13],
                [self next:430 element:@2],
                [self next:450 element:@9],
                [self next:520 element:@11],
                [self next:560 element:@20],
        ]];

        __block RxObservable<NSNumber *> *ys = nil;
        __block id<RxDisposable> subscription1 = nil;
        __block id<RxDisposable> subscription2 = nil;

        __block RxTestableObserver<NSNumber *> *res1 = [scheduler createObserver];
        __block RxTestableObserver<NSNumber *> *res2 = [scheduler createObserver];

        [scheduler scheduleAt:RxTestSchedulerDefaultCreated action:^{ ys = transform([xs asObservable]); }];

        [scheduler scheduleAt:335 action:^{ subscription1 = [ys subscribe:res1]; }];
        [scheduler scheduleAt:400 action:^{ [subscription1 dispose]; }];

        [scheduler scheduleAt:355 action:^{ subscription2 = [ys subscribe:res2]; }];
        [scheduler scheduleAt:415 action:^{ [subscription2 dispose]; }];

        [scheduler scheduleAt:440 action:^{ subscription1 = [ys subscribe:res1]; }];
        [scheduler scheduleAt:455 action:^{ [subscription1 dispose]; }];

        [scheduler start];

        NSArray *array = @[
                // 1rt batch
                [self next:340 element:@8],
                [self next:360 element:@5],
                [self completed:365],

                // 2nd batch
                [self next:440 element:@5],
                [self completed:440]
        ];
        XCTAssert([res1.events isEqualToArray:array]);

        NSArray *array1 = @[
                [self next:355 element:@8],
                [self next:360 element:@5],
                [self completed:365]
        ];
        XCTAssert([res2.events isEqualToArray:array1]);

        // unoptimized version of replay subject will make a subscription and kill it immediatelly
        XCTAssert([xs.subscriptions.firstObject isEqual:[RxSubscription createWithSubscribe:335 unsubscribe:365]]);
        XCTAssert(xs.subscriptions.count <= 2);
        XCTAssert(xs.subscriptions.count == 1 || [xs.subscriptions[1] isEqual:[RxSubscription createWithSubscribe:440 unsubscribe:440]]);
    }];
}

- (void)testShareReplay1_Canceled {
    [self _testIdenticalBehaviorOfShareReplayOptimizedAndComposed:^(RxObservable<NSNumber *> *(^transform)(RxObservable<NSNumber *> *)) {
        RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

        RxTestableObservable *xs = [scheduler createHotObservable:@[
                [self completed:365],
                [self next:370 element:@6],
                [self next:390 element:@7],
                [self next:410 element:@13],
                [self next:430 element:@2],
                [self next:450 element:@9],
                [self next:520 element:@11],
                [self next:560 element:@20],
        ]];

        __block RxObservable<NSNumber *> *ys = nil;
        __block id<RxDisposable> subscription1 = nil;
        __block id<RxDisposable> subscription2 = nil;

        __block RxTestableObserver<NSNumber *> *res1 = [scheduler createObserver];
        __block RxTestableObserver<NSNumber *> *res2 = [scheduler createObserver];

        [scheduler scheduleAt:RxTestSchedulerDefaultCreated action:^{ ys = transform([xs asObservable]); }];

        [scheduler scheduleAt:335 action:^{ subscription1 = [ys subscribe:res1]; }];
        [scheduler scheduleAt:400 action:^{ [subscription1 dispose]; }];

        [scheduler scheduleAt:355 action:^{ subscription2 = [ys subscribe:res2]; }];
        [scheduler scheduleAt:415 action:^{ [subscription2 dispose]; }];

        [scheduler scheduleAt:440 action:^{ subscription1 = [ys subscribe:res1]; }];
        [scheduler scheduleAt:455 action:^{ [subscription1 dispose]; }];

        [scheduler start];

        NSArray *array = @[
                // 1rt batch
                [self completed:365],

                // 2nd batch
                [self completed:440]
        ];
        XCTAssert([res1.events isEqualToArray:array]);

        NSArray *array1 = @[
                [self completed:365]
        ];
        XCTAssert([res2.events isEqualToArray:array1]);

        // unoptimized version of replay subject will make a subscription and kill it immediatelly
        XCTAssert([xs.subscriptions.firstObject isEqual:[RxSubscription createWithSubscribe:335 unsubscribe:365]]);
        XCTAssert(xs.subscriptions.count <= 2);
        XCTAssert(xs.subscriptions.count == 1 || [xs.subscriptions[1] isEqual:[RxSubscription createWithSubscribe:440 unsubscribe:440]]);
    }];
}

@end

@implementation RxObservableBindingTest (ShareReplayLatestWhileConnected)

- (void)testShareReplayLatestWhileConnected_DeadlockImmediatelly {
    __block int nEvents = 0;
    RxObservable *observable = [[RxObservable of:@[@0, @1, @2]] shareReplayLatestWhileConnected];
    [observable subscribeNext:^(id o) {
        nEvents++;
    }];
    XCTAssertTrue(nEvents == 3);
}

- (void)testShareReplayLatestWhileConnected_DeadlockEmpty {
    __block int nEvents = 0;
    RxObservable *observable = [[RxObservable empty] shareReplayLatestWhileConnected];
    [observable subscribeCompleted:^ {
        nEvents++;
    }];
    XCTAssertTrue(nEvents == 1);
}

- (void)testShareReplayLatestWhileConnected_DeadlockError {
    __block int nEvents = 0;
    RxObservable *observable = [[RxObservable error:[RxTestError testError]] shareReplayLatestWhileConnected];
    [observable subscribeError:^(NSError *error) {
        nEvents++;
    }];
    XCTAssertTrue(nEvents == 1);
}

- (void)testShareReplayLatestWhileConnected_DeadlockErrorAfterN {
    __block int nEvents = 0;
    RxObservable *observable = [[@[[RxObservable of:@[@0, @1, @2]], [RxObservable error:[RxTestError testError]]] concat] shareReplayLatestWhileConnected];
    [observable subscribeError:^(NSError *error) {
        nEvents++;
    }];
    XCTAssertTrue(nEvents == 1);
}

- (void)testShareReplayLatestWhileConnected_Basic {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
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

    __block RxObservable<NSNumber *> *ys = nil;
    __block id<RxDisposable> subscription1 = nil;
    __block id<RxDisposable> subscription2 = nil;

    __block RxTestableObserver<NSNumber *> *res1 = [scheduler createObserver];
    __block RxTestableObserver<NSNumber *> *res2 = [scheduler createObserver];

    [scheduler scheduleAt:RxTestSchedulerDefaultCreated action:^{ ys = [xs shareReplayLatestWhileConnected]; }];

    [scheduler scheduleAt:335 action:^{ subscription1 = [ys subscribe:res1]; }];
    [scheduler scheduleAt:400 action:^{ [subscription1 dispose]; }];

    [scheduler scheduleAt:355 action:^{ subscription2 = [ys subscribe:res2]; }];
    [scheduler scheduleAt:415 action:^{ [subscription2 dispose]; }];

    [scheduler scheduleAt:440 action:^{ subscription1 = [ys subscribe:res1]; }];
    [scheduler scheduleAt:455 action:^{ [subscription1 dispose]; }];

    [scheduler start];

    NSArray *array = @[
            // 1rt batch
            [self next:340 element:@8],
            [self next:360 element:@5],
            [self next:370 element:@6],
            [self next:390 element:@7],

            // 2nd batch
            [self next:450 element:@9],
    ];
    XCTAssert([res1.events isEqualToArray:array]);

    NSArray *array1 = @[
            [self next:355 element:@8],
            [self next:360 element:@5],
            [self next:370 element:@6],
            [self next:390 element:@7],
            [self next:410 element:@13],
    ];

    XCTAssert([res2.events isEqualToArray:array1]);

    NSArray *sub = @[
            [RxSubscription createWithSubscribe:335 unsubscribe:415],
            [RxSubscription createWithSubscribe:440 unsubscribe:455],
    ];
    XCTAssert([xs.subscriptions isEqualToArray:sub]);
}

- (void)testShareReplayLatestWhileConnected_Error {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:110 element:@7],
            [self next:220 element:@3],
            [self next:280 element:@4],
            [self next:290 element:@1],
            [self next:340 element:@8],
            [self next:360 element:@5],
            [self error:365 testError:[RxTestError testError]],
            [self next:370 element:@6],
            [self next:390 element:@7],
            [self next:410 element:@13],
            [self next:430 element:@2],
            [self next:450 element:@9],
            [self next:520 element:@11],
            [self next:560 element:@20],
    ]];

    __block RxObservable<NSNumber *> *ys = nil;
    __block id<RxDisposable> subscription1 = nil;
    __block id<RxDisposable> subscription2 = nil;

    __block RxTestableObserver<NSNumber *> *res1 = [scheduler createObserver];
    __block RxTestableObserver<NSNumber *> *res2 = [scheduler createObserver];

    [scheduler scheduleAt:RxTestSchedulerDefaultCreated action:^{ ys = [xs shareReplayLatestWhileConnected]; }];

    [scheduler scheduleAt:335 action:^{ subscription1 = [ys subscribe:res1]; }];
    [scheduler scheduleAt:400 action:^{ [subscription1 dispose]; }];

    [scheduler scheduleAt:355 action:^{ subscription2 = [ys subscribe:res2]; }];
    [scheduler scheduleAt:415 action:^{ [subscription2 dispose]; }];

    [scheduler scheduleAt:440 action:^{ subscription1 = [ys subscribe:res1]; }];
    [scheduler scheduleAt:455 action:^{ [subscription1 dispose]; }];

    [scheduler start];

    NSArray *array = @[
            // 1rt batch
            [self next:340 element:@8],
            [self next:360 element:@5],
            [self error:365 testError:[RxTestError testError]],

            // 2nd batch
            [self next:450 element:@9],
    ];
    XCTAssert([res1.events isEqualToArray:array]);

    NSArray *array1 = @[
            [self next:355 element:@8],
            [self next:360 element:@5],
            [self error:365 testError:[RxTestError testError]],
    ];

    XCTAssert([res2.events isEqualToArray:array1]);

    NSArray *sub = @[
            [RxSubscription createWithSubscribe:335 unsubscribe:365],
            [RxSubscription createWithSubscribe:440 unsubscribe:455],
    ];
    XCTAssert([xs.subscriptions isEqualToArray:sub]);
}

- (void)testShareReplayLatestWhileConnected_Completed {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:110 element:@7],
            [self next:220 element:@3],
            [self next:280 element:@4],
            [self next:290 element:@1],
            [self next:340 element:@8],
            [self next:360 element:@5],
            [self completed:365],
            [self next:370 element:@6],
            [self next:390 element:@7],
            [self next:410 element:@13],
            [self next:430 element:@2],
            [self next:450 element:@9],
            [self next:520 element:@11],
            [self next:560 element:@20],
    ]];

    __block RxObservable<NSNumber *> *ys = nil;
    __block id<RxDisposable> subscription1 = nil;
    __block id<RxDisposable> subscription2 = nil;

    __block RxTestableObserver<NSNumber *> *res1 = [scheduler createObserver];
    __block RxTestableObserver<NSNumber *> *res2 = [scheduler createObserver];

    [scheduler scheduleAt:RxTestSchedulerDefaultCreated action:^{ ys = [xs shareReplayLatestWhileConnected]; }];

    [scheduler scheduleAt:335 action:^{ subscription1 = [ys subscribe:res1]; }];
    [scheduler scheduleAt:400 action:^{ [subscription1 dispose]; }];

    [scheduler scheduleAt:355 action:^{ subscription2 = [ys subscribe:res2]; }];
    [scheduler scheduleAt:415 action:^{ [subscription2 dispose]; }];

    [scheduler scheduleAt:440 action:^{ subscription1 = [ys subscribe:res1]; }];
    [scheduler scheduleAt:455 action:^{ [subscription1 dispose]; }];

    [scheduler start];

    NSArray *array = @[
            // 1rt batch
            [self next:340 element:@8],
            [self next:360 element:@5],
            [self completed:365],

            // 2nd batch
            [self next:450 element:@9],
    ];
    XCTAssert([res1.events isEqualToArray:array]);

    NSArray *array1 = @[
            [self next:355 element:@8],
            [self next:360 element:@5],
            [self completed:365],
    ];

    XCTAssert([res2.events isEqualToArray:array1]);

    NSArray *sub = @[
            [RxSubscription createWithSubscribe:335 unsubscribe:365],
            [RxSubscription createWithSubscribe:440 unsubscribe:455],
    ];
    XCTAssert([xs.subscriptions isEqualToArray:sub]);
}

@end

#pragma clang diagnostic pop