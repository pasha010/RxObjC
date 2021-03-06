//
//  RxObservable+ConcurrencyTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 10.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"
#import "RxTestError.h"
#import "RxPrimitiveHotObservable.h"
#import "RxPrimitiveMockObserver.h"
#import "XCTest+Rx.h"

@interface RxObservableConcurrencyTestBase : RxTest

- (void)performLocked:(dispatch_block_t)action;

@end

@implementation RxObservableConcurrencyTestBase {
    NSLock *__nullable _lock;
}

- (void)setUp {
    [super setUp];
    _lock = [[NSLock alloc] init];
}

- (void)tearDown {
    [super tearDown];
    _lock = nil;
}

- (void)performLocked:(dispatch_block_t)action {
    [_lock lock];
    action();
    [_lock unlock];
}

@end

@interface RxObservableConcurrencyTest : RxObservableConcurrencyTestBase
@end

@implementation RxObservableConcurrencyTest
@end

typedef id <RxDisposable> __nonnull (^RxObservableConcurrencyTests)(RxSerialDispatchQueueScheduler *__nonnull scheduler); 

@implementation RxObservableConcurrencyTest (ObserveOn)

- (void)runDispatchQueueSchedulerTests:(nonnull RxObservableConcurrencyTests)tests {
    RxSerialDispatchQueueScheduler *scheduler = [[RxSerialDispatchQueueScheduler alloc] initWithInternalSerialQueueName:@"testQueue1"];
    [[self runDispatchQueueSchedulerTests:scheduler tests:tests] dispose];
}

- (nonnull id <RxDisposable>)runDispatchQueueSchedulerTests:(nonnull RxSerialDispatchQueueScheduler *)scheduler tests:(nonnull RxObservableConcurrencyTests)tests {
    // simplest possible solution, even though it has horrible efficiency in this case probably
    id <RxDisposable> disposable = tests(scheduler);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for all tests to complete"];

    [scheduler schedule:nil action:^id <RxDisposable>(RxStateType __nullable s) {
        [expectation fulfill];
        return [RxNopDisposable sharedInstance];
    }];
    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError *error) {
        XCTAssertTrue(error == nil, @"Everything not completed in 1.0 sec.");
    }];
    return disposable;
}

- (void)runDispatchQueueSchedulerMultiplexedTests:(nonnull NSArray<RxObservableConcurrencyTests> *)tests {
    RxSerialDispatchQueueScheduler *scheduler = [[RxSerialDispatchQueueScheduler alloc] initWithInternalSerialQueueName:@"testQueue1"];
    RxCompositeDisposable *compositeDisposable = [[RxCompositeDisposable alloc] init];
    for (RxObservableConcurrencyTests test in tests) {
        [compositeDisposable addDisposable:[self runDispatchQueueSchedulerTests:scheduler tests:test]];
    }
    [compositeDisposable dispose];
}

- (void)testObserveOnDispatchQueue_DoesPerformWorkOnQueue {
    NSThread *unitTestsThread = [NSThread currentThread];
    
    __block BOOL didExecute = NO;
    
    [self runDispatchQueueSchedulerTests:^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
        RxObservable *observable = [[RxObservable just:@0] observeOn:scheduler];
        return [observable subscribeNext:^(NSNumber *n) {
            didExecute = YES;
            XCTAssert(![[NSThread currentThread] isEqual:unitTestsThread]);
        }];
    }];
}

#if TRACE_RESOURCES

- (void)testObserveOnDispatchQueue_EnsureCorrectImplementationIsChosen {
    [self runDispatchQueueSchedulerTests:^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
        XCTAssert(rx_numberOfSerialDispatchQueueObservables == 0);
        __unused RxObservable *a = [[RxObservable just:@0] observeOn:scheduler];
        XCTAssert(rx_numberOfSerialDispatchQueueObservables == 1);
        return [RxNopDisposable sharedInstance];
    }];
}

- (void)testObserveOnDispatchQueue_DispatchQueueSchedulerIsSerial {
    __block int32_t numberOfConcurrentEvents = 0;
    __block int32_t numberOfExecutions = 0;
    
    [self runDispatchQueueSchedulerTests:^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
        XCTAssert(rx_numberOfSerialDispatchQueueObservables == 0);
        id <RxDisposable> (^action)(id) = ^(id _) {
            XCTAssert(OSAtomicIncrement32(&numberOfConcurrentEvents) == 1);
            [self sleep:0.1]; // should be enough to block the queue, so if it's concurrent, it will fail
            XCTAssert(OSAtomicDecrement32(&numberOfConcurrentEvents) == 0);
            OSAtomicIncrement32(&numberOfExecutions);
            return [RxNopDisposable sharedInstance];
        };
        [scheduler schedule:nil action:action];
        [scheduler schedule:nil action:action];
        return [RxNopDisposable sharedInstance];
    }];

    XCTAssert(rx_numberOfSerialDispatchQueueObservables == 0);
    XCTAssert(numberOfExecutions == 2);
}

#endif

- (void)testObserveOnDispatchQueue_DeadlockErrorImmediatelly {
    __block int nEvents = 0;
    
    [self runDispatchQueueSchedulerTests:^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
        RxObservable *observable = [[RxObservable error:[RxTestError testError]] observeOn:scheduler];
        return [observable subscribeError:^(NSError *error) {
            nEvents++;
        }];
    }];
    XCTAssert(nEvents == 1);
}

- (void)testObserveOnDispatchQueue_DeadlockEmpty {
    __block int nEvents = 0;

    [self runDispatchQueueSchedulerTests:^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
        RxObservable *observable = [[RxObservable empty] observeOn:scheduler];
        return [observable subscribeCompleted:^{
            nEvents++;
        }];
    }];
    XCTAssert(nEvents == 1);
}

- (void)testObserveOnDispatchQueue_Never {
    [self runDispatchQueueSchedulerTests:^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
        RxObservable *xs = [RxObservable never];
        return [[xs.asObservable observeOn:scheduler] subscribeNext:^(id o) {
            XCTAssert(NO);
        }];
    }];
}

- (void)testObserveOnDispatchQueue_Simple {
    RxPrimitiveHotObservable *xs = [[RxPrimitiveHotObservable alloc] init];
    RxPrimitiveMockObserver *observer = [[RxPrimitiveMockObserver alloc] init];

    [self runDispatchQueueSchedulerMultiplexedTests:@[
            ^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
                id <RxDisposable> subscription = [[xs.asObservable observeOn:scheduler] subscribe:observer];
                XCTAssert([xs.subscriptions isEqualToArray:@[RxSubscribedToHotObservable()]]);
                rx_onNext(xs, @0);
                return subscription;
            },
            ^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
                BOOL b = [observer.events isEqualToArray:@[[self next:@0]]];
                XCTAssert(b);
                rx_onNext(xs, @1);
                rx_onNext(xs, @2);
                return [RxNopDisposable sharedInstance];
            },
            ^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
                BOOL b = [observer.events isEqualToArray:@[[self next:@0], [self next:@1], [self next:@2]]];
                XCTAssert(b);
                XCTAssert([xs.subscriptions isEqualToArray:@[RxSubscribedToHotObservable()]]);
                rx_onCompleted(xs);
                return [RxNopDisposable sharedInstance];
            },
            ^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
                BOOL b = [observer.events isEqualToArray:@[[self next:@0], [self next:@1], [self next:@2], [self completed]]];
                XCTAssert(b);
                XCTAssert([xs.subscriptions isEqualToArray:@[RxUnsunscribedFromHotObservable()]]);
                return [RxNopDisposable sharedInstance];
            }
    ]];
}

- (void)testObserveOnDispatchQueue_Empty {
    RxPrimitiveHotObservable *xs = [[RxPrimitiveHotObservable alloc] init];
    RxPrimitiveMockObserver *observer = [[RxPrimitiveMockObserver alloc] init];
    
    [self runDispatchQueueSchedulerMultiplexedTests:@[
            ^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
                id <RxDisposable> subscription = [[xs.asObservable observeOn:scheduler] subscribe:observer];
                XCTAssert([xs.subscriptions isEqualToArray:@[RxSubscribedToHotObservable()]]);
                rx_onCompleted(xs);
                return subscription;
            },
            ^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
                XCTAssert([observer.events isEqualToArray:@[[self completed]]]);
                XCTAssert([xs.subscriptions isEqualToArray:@[RxUnsunscribedFromHotObservable()]]);
                return [RxNopDisposable sharedInstance];
            }
    ]];
}

- (void)testObserveOnDispatchQueue_Error {
    RxPrimitiveHotObservable *xs = [[RxPrimitiveHotObservable alloc] init];
    RxPrimitiveMockObserver *observer = [[RxPrimitiveMockObserver alloc] init];

    [self runDispatchQueueSchedulerMultiplexedTests:@[
            ^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
                id <RxDisposable> subscription = [[xs.asObservable observeOn:scheduler] subscribe:observer];
                XCTAssert([xs.subscriptions isEqualToArray:@[RxSubscribedToHotObservable()]]);
                rx_onNext(xs, @0);
                return subscription;
            },
            ^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
                BOOL b = [observer.events isEqualToArray:@[[self next:@0]]];
                XCTAssert(b);
                rx_onNext(xs, @1);
                rx_onNext(xs, @2);
                return [RxNopDisposable sharedInstance];
            },
            ^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
                BOOL b = [observer.events isEqualToArray:@[
                        [self next:@0],
                        [self next:@1],
                        [self next:@2]]];
                XCTAssert(b);
                XCTAssert([xs.subscriptions isEqualToArray:@[RxSubscribedToHotObservable()]]);
                rx_onError(xs, [RxTestError testError]);
                return [RxNopDisposable sharedInstance];
            },
            ^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
                BOOL b = [observer.events isEqualToArray:@[
                        [self next:@0],
                        [self next:@1],
                        [self next:@2],
                        [self error:[RxTestError testError]]]];
                XCTAssert(b);
                XCTAssert([xs.subscriptions isEqualToArray:@[RxUnsunscribedFromHotObservable()]]);
                return [RxNopDisposable sharedInstance];
            }
    ]];
}

- (void)testObserveOnDispatchQueue_Dispose {
    RxPrimitiveHotObservable *xs = [[RxPrimitiveHotObservable alloc] init];
    RxPrimitiveMockObserver *observer = [[RxPrimitiveMockObserver alloc] init];
    __block id <RxDisposable> subscription = nil;

    [self runDispatchQueueSchedulerMultiplexedTests:@[
            ^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
                subscription = [[xs.asObservable observeOn:scheduler] subscribe:observer];
                XCTAssert([xs.subscriptions isEqualToArray:@[RxSubscribedToHotObservable()]]);
                rx_onNext(xs, @0);
                return subscription;
            },
            ^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
                BOOL b = [observer.events isEqualToArray:@[[self next:@0]]];
                XCTAssert(b);
                XCTAssert([xs.subscriptions isEqualToArray:@[RxSubscribedToHotObservable()]]);
                [subscription dispose];
                XCTAssert([xs.subscriptions isEqualToArray:@[RxUnsunscribedFromHotObservable()]]);

                rx_onError(xs, [RxTestError testError]);

                return [RxNopDisposable sharedInstance];
            },
            ^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
                BOOL b = [observer.events isEqualToArray:@[[self next:@0]]];
                XCTAssert(b);
                XCTAssert([xs.subscriptions isEqualToArray:@[RxUnsunscribedFromHotObservable()]]);
                return [RxNopDisposable sharedInstance];
            }
    ]];
}

@end

@interface RxObservableConcurrentSchedulerConcurrencyTest : RxObservableConcurrencyTestBase
@end

@implementation RxObservableConcurrentSchedulerConcurrencyTest

- (nonnull RxImmediateScheduler *)createScheduler {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 8;
    return [[RxOperationQueueScheduler alloc] initWithOperationQueue:queue];
}

#if TRACE_RESOURCES
- (void)testObserveOn_EnsureCorrectImplementationIsChosen {
    RxImmediateScheduler *scheduler = [self createScheduler];
    XCTAssert(rx_numberOfSerialDispatchQueueObservables == 0);
    [[RxObservable just:@0] observeOn:scheduler];
    [self sleep:0.1];
    XCTAssert(rx_numberOfSerialDispatchQueueObservables == 0);
}
#endif

- (void)testObserveOn_EnsureTestsAreExecutedWithRealConcurrentScheduler {
    NSMutableArray<NSString *> *events = [NSMutableArray array];

    RxBehaviorSubject *stop = [RxBehaviorSubject create:@0];

    RxImmediateScheduler *scheduler = [self createScheduler];

    NSCondition *condition = [[NSCondition alloc] init];
    
    __block NSInteger writtenStarted = 0; 
    __block NSInteger writtenEnded = 0;

    id <RxDisposable> (^concurrent)(id)=^id <RxDisposable> (id _) {
        [self performLocked:^{
            [events addObject:@"Started"];
        }];

        [condition lock];
        writtenStarted++;
        [condition signal];
        
        while (writtenStarted < 2) {
            [condition wait];
        }
        [condition unlock];

        [self performLocked:^{
            [events addObject:@"Ended"];
        }];

        [condition lock];
        writtenEnded++;
        [condition signal];
        while (writtenEnded < 2) {
            [condition wait];
        }
        [condition unlock];

        rx_onCompleted(stop);

        return [RxNopDisposable sharedInstance];
    };

    [scheduler schedule:nil action:concurrent];

    [scheduler schedule:nil action:concurrent];

    [[stop toBlocking] blocking_last];

    NSArray *array = @[@"Started", @"Started", @"Ended", @"Ended"];
    XCTAssertEqualObjects(events, array);
}

- (void)testObserveOn_Never {
    RxImmediateScheduler *scheduler = [self createScheduler];

    RxObservable *xs = [RxObservable never];

    id <RxDisposable> subscription = [[xs.asObservable observeOn:scheduler] subscribeNext:^(id o) {
        XCTAssert(NO);
    }];

    [self sleep:0.1];

    [subscription dispose];
}

- (void)testObserveOn_Simple {
    RxPrimitiveHotObservable *xs = [[RxPrimitiveHotObservable alloc] init];
    RxPrimitiveMockObserver *observer = [[RxPrimitiveMockObserver alloc] init];

    RxImmediateScheduler *scheduler = [self createScheduler];

    id <RxDisposable> subscription = [[xs.asObservable observeOn:scheduler] subscribe:observer];

    XCTAssert([xs.subscriptions isEqualToArray:@[RxSubscribedToHotObservable()]]);
    rx_onNext(xs, @0);

    [self sleep:0.1];

    BOOL b = [observer.events isEqualToArray:@[[self next:@0]]];
    XCTAssert(b);

    rx_onNext(xs, @1);
    rx_onNext(xs, @2);

    [self sleep:0.1];

    NSArray *events = @[
            [self next:@0],
            [self next:@1],
            [self next:@2],
    ];
    XCTAssertEqualObjects(observer.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[RxSubscribedToHotObservable()]);

    rx_onCompleted(xs);

    [self sleep:0.1];

    NSArray *array = @[
            [self next:@0],
            [self next:@1],
            [self next:@2],
            [self completed]
    ];
    XCTAssertEqualObjects(observer.events, array);

    [subscription dispose];

    [self sleep:0.1];
}

- (void)testObserveOn_Empty {
    RxPrimitiveHotObservable *xs = [[RxPrimitiveHotObservable alloc] init];
    RxPrimitiveMockObserver *observer = [[RxPrimitiveMockObserver alloc] init];

    RxImmediateScheduler *scheduler = [self createScheduler];

    [[xs.asObservable observeOn:scheduler] subscribe:observer];

    XCTAssertEqualObjects(xs.subscriptions, @[RxSubscribedToHotObservable()]);
    rx_onCompleted(xs);

    [self sleep:0.1];

    XCTAssertEqualObjects(observer.events, @[completed(0)]);
    XCTAssertEqualObjects(xs.subscriptions, @[RxUnsunscribedFromHotObservable()]);
}

- (void)testObserveOn_ConcurrentSchedulerIsSerialized {
    RxPrimitiveHotObservable *xs = [[RxPrimitiveHotObservable alloc] init];
    RxPrimitiveMockObserver *observer = [[RxPrimitiveMockObserver alloc] init];
    
    __block BOOL executed = NO;

    RxImmediateScheduler *scheduler = [self createScheduler];

    RxObservable<NSNumber *> *res = [[xs.asObservable observeOn:scheduler] map:^NSNumber *(NSNumber *v) {
        if (v.integerValue == 0) {
            [self sleep:0.1]; // 100 ms is enough
            executed = YES;
        }
        return v;
    }];

    id <RxDisposable> subscription = [res subscribe:observer];

    XCTAssert([xs.subscriptions isEqualToArray:@[RxSubscribedToHotObservable()]]);
    rx_onNext(xs, @0);
    rx_onNext(xs, @1);
    rx_onCompleted(xs);

    [self sleep:0.1];

    NSArray *array = @[
            [self next:@0],
            [self next:@1],
            [self completed]];

    [self sleep:0.1];
    XCTAssert([observer.events isEqualToArray:array]);

    XCTAssert([xs.subscriptions isEqualToArray:@[RxUnsunscribedFromHotObservable()]]);
    XCTAssert(executed);

    [subscription dispose];
}

- (void)testObserveOn_Error {
    RxPrimitiveHotObservable *xs = [[RxPrimitiveHotObservable alloc] init];
    RxPrimitiveMockObserver *observer = [[RxPrimitiveMockObserver alloc] init];

    RxImmediateScheduler *scheduler = [self createScheduler];

    [[xs.asObservable observeOn:scheduler] subscribe:observer];

    XCTAssert([xs.subscriptions isEqualToArray:@[RxSubscribedToHotObservable()]]);
    rx_onNext(xs, @0);

    [self sleep:0.1];

    XCTAssert([observer.events isEqualToArray:@[[self next:@0]]]);
    rx_onNext(xs, @1);
    rx_onNext(xs, @2);

    [self sleep:0.1];

    NSArray *array = @[
            [self next:@0],
            [self next:@1],
            [self next:@2],];

    XCTAssert([observer.events isEqualToArray:array]);
    XCTAssert([xs.subscriptions isEqualToArray:@[RxSubscribedToHotObservable()]]);

    rx_onError(xs, [RxTestError testError]);

    [self sleep:0.1];

    NSArray *a = @[
            [self next:@0],
            [self next:@1],
            [self next:@2],
            [self error:[RxTestError testError]]
    ];

    XCTAssert([observer.events isEqualToArray:a]);
    XCTAssert([xs.subscriptions isEqualToArray:@[RxUnsunscribedFromHotObservable()]]);
}

- (void)testObserveOn_Dispose {
    RxPrimitiveHotObservable *xs = [[RxPrimitiveHotObservable alloc] init];
    RxPrimitiveMockObserver *observer = [[RxPrimitiveMockObserver alloc] init];

    RxImmediateScheduler *scheduler = [self createScheduler];
    id <RxDisposable> subscription = [[xs.asObservable observeOn:scheduler] subscribe:observer];
    XCTAssert([xs.subscriptions isEqualToArray:@[RxSubscribedToHotObservable()]]);
    rx_onNext(xs, @0);

    [self sleep:0.1];

    XCTAssert([observer.events isEqualToArray:@[[self next:@0]]]);
    XCTAssert([xs.subscriptions isEqualToArray:@[RxSubscribedToHotObservable()]]);
    [subscription dispose];
    XCTAssert([xs.subscriptions isEqualToArray:@[RxUnsunscribedFromHotObservable()]]);

    rx_onError(xs, [RxTestError testError]);

    [self sleep:0.1];

    NSArray *array = @[
            [self next:@0]
    ];

    XCTAssert([observer.events isEqualToArray:array]);
    XCTAssert([xs.subscriptions isEqualToArray:@[RxUnsunscribedFromHotObservable()]]);
}

@end

@interface RxObservableConcurrentSchedulerConcurrencyTest2 : RxObservableConcurrentSchedulerConcurrencyTest
@end

@implementation RxObservableConcurrentSchedulerConcurrencyTest2

- (nonnull id <RxImmediateSchedulerType>)createScheduler {
    return [[RxConcurrentDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOS:[RxDispatchQueueSchedulerQOS default]];
}

@end

@implementation RxObservableConcurrencyTest (SubscribeOn)

- (void)testSubscribeOn_SchedulerSleep {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];
    
    __block NSInteger scheduled = 0;
    __block NSInteger disposed = 0;

    RxObservable *xs = [RxObservable create:^id <RxDisposable>(RxAnyObserver *observer) {
        scheduled = scheduler.clock.integerValue;
        return [RxAnonymousDisposable create:^{
            disposed = scheduler.clock.integerValue;
        }];
    }];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs subscribeOn:scheduler];
    }];
    
    XCTAssert([res.events isEqualToArray:@[]]);
    
    XCTAssert(scheduled == 201);
    XCTAssert(disposed == 1001);
}

- (void)testSubscribeOn_SchedulerCompleted {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self completed:300]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs.asObservable subscribeOn:scheduler];
    }];

    XCTAssertEqualObjects(res.events, @[[self completed:300]]);
    XCTAssertEqualObjects(xs.subscriptions, @[[RxSubscription createWithSubscribe:201 unsubscribe:300]]);
}

- (void)testSubscribeOn_SchedulerError {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self error:300 testError:[RxTestError testError]]
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs.asObservable subscribeOn:scheduler];
    }];

    XCTAssertEqualObjects(res.events, @[[self error:300 testError:[RxTestError testError]]]);
    XCTAssertEqualObjects(xs.subscriptions, @[[RxSubscription createWithSubscribe:201 unsubscribe:300]]);
}

- (void)testSubscribeOn_SchedulerDispose {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            [self next:150 element:@1],
            [self next:210 element:@2],
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [xs.asObservable subscribeOn:scheduler];
    }];

    XCTAssert([res.events isEqualToArray:@[[self next:210 element:@2]]]);

    XCTAssert([xs.subscriptions isEqualToArray:@[[RxSubscription createWithSubscribe:201 unsubscribe:1001]]]);
}

@end
