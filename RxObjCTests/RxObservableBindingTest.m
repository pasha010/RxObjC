//
//  RxObservableBindingTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RxObservable+RxBinding.h"
#import "RxTest.h"
#import "RxTestScheduler.h"
#import "XCTest+Rx.h"
#import "RxTestableObservable.h"
#import "RxPublishSubject.h"
#import "RxTestableObserver.h"
#import "RxSubscription.h"
#import "RxTestError.h"
#import "RxObservable+RxZip.h"

@interface RxObservableBindingTest : RxTest

@end

@implementation RxObservableBindingTest

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

// TODO implement test mock objects

- (void)testRefCount_Error {
//    RxObservable<NSNumber *> *xs = [RxObservable error:[RxTestError testError]];
    /*
     * let xs: Observable<Int> = Observable.error(testError)

        let res = xs.publish().refCount()
        _ = res.subscribe { event in
            switch event {
            case .Next:
                XCTAssertTrue(false)
            case .Error(let error):
                XCTAssertErrorEqual(error, testError)
            case .Completed:
                XCTAssertTrue(false)
            }
        }
        _ = res.subscribe { event in
            switch event {
            case .Next:
                XCTAssertTrue(false)
            case .Error(let error):
                XCTAssertErrorEqual(error, testError)
            case .Completed:
                XCTAssertTrue(false)
            }
        }
     */
}

- (void)testRefCount_Publish {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:210 element:@1],
    ]];

//    [[xs publish] refCount];
    /*
     * let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            next(230, 3),
            next(240, 4),
            next(250, 5),
            next(260, 6),
            next(270, 7),
            next(280, 8),
            next(290, 9),
            completed(300)
        ])
        
        let res = xs.publish().refCount()
        
        var d1: Disposable!
        let o1 = scheduler.createObserver(Int)
        scheduler.scheduleAt(215) { d1 = res.subscribe(o1) }
        scheduler.scheduleAt(235) { d1.dispose() }
        
        var d2: Disposable!
        let o2 = scheduler.createObserver(Int)
        scheduler.scheduleAt(225) { d2 = res.subscribe(o2) }
        scheduler.scheduleAt(275) { d2.dispose() }
        
        var d3: Disposable!
        let o3 = scheduler.createObserver(Int)
        scheduler.scheduleAt(255) { d3 = res.subscribe(o3) }
        scheduler.scheduleAt(265) { d3.dispose() }
        
        var d4: Disposable!
        let o4 = scheduler.createObserver(Int)
        scheduler.scheduleAt(285) { d4 = res.subscribe(o4) }
        scheduler.scheduleAt(320) { d4.dispose() }
        
        scheduler.start()
        
        XCTAssertEqual(o1.events, [
            next(220, 2),
            next(230, 3)
        ])
        
        XCTAssertEqual(o2.events, [
            next(230, 3),
            next(240, 4),
            next(250, 5),
            next(260, 6),
            next(270, 7)
        ])
        
        XCTAssertEqual(o3.events, [
            next(260, 6)
        ])
        
        XCTAssertEqual(o4.events, [
            next(290, 9),
            completed(300)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(215, 275),
            Subscription(285, 300)
        ])
     */
}

@end
