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

- (void)performLocked:(dispatch_block_t)action {
    if (!_lock) {
        _lock = [[NSLock alloc] init];
    }
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
        RxObservable *a = [[RxObservable just:@0] observeOn:scheduler];
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
        return [[xs observeOn:scheduler] subscribeNext:^(id o) {
            XCTAssert(NO);
        }];
    }];
}

- (void)testObserveOnDispatchQueue_Simple {
    RxPrimitiveHotObservable *xs = [[RxPrimitiveHotObservable alloc] init];
    RxPrimitiveMockObserver *observer = [[RxPrimitiveMockObserver alloc] init];

    [self runDispatchQueueSchedulerMultiplexedTests:@[
            ^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
                id <RxDisposable> subscription = [[xs observeOn:scheduler] subscribe:observer];
                XCTAssert([xs.subscriptions isEqualToArray:@[RxSubscribedToHotObservable()]]);
                [xs onNext:@0];
                return subscription;
            },
            ^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
                BOOL b = [observer.events isEqualToArray:@[[self next:@0]]];
                XCTAssert(b);
                [xs onNext:@1];
                [xs onNext:@2];
                return [RxNopDisposable sharedInstance];
            },
            ^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
                BOOL b = [observer.events isEqualToArray:@[[self next:@0], [self next:@1], [self next:@2]]];
                XCTAssert(b);
                XCTAssert([xs.subscriptions isEqualToArray:@[RxSubscribedToHotObservable()]]);
                [xs onCompleted];
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
                id <RxDisposable> subscription = [[xs observeOn:scheduler] subscribe:observer];
                XCTAssert([xs.subscriptions isEqualToArray:@[RxSubscribedToHotObservable()]]);
                [xs onCompleted];
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
                id <RxDisposable> subscription = [[xs observeOn:scheduler] subscribe:observer];
                XCTAssert([xs.subscriptions isEqualToArray:@[RxSubscribedToHotObservable()]]);
                [xs onNext:@0];
                return subscription;
            },
            ^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
                BOOL b = [observer.events isEqualToArray:@[[self next:@0]]];
                XCTAssert(b);
                [xs onNext:@1];
                [xs onNext:@2];
                return [RxNopDisposable sharedInstance];
            },
            ^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
                BOOL b = [observer.events isEqualToArray:@[
                        [self next:@0],
                        [self next:@1],
                        [self next:@2]]];
                XCTAssert(b);
                XCTAssert([xs.subscriptions isEqualToArray:@[RxSubscribedToHotObservable()]]);
                [xs onError:[RxTestError testError]];
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
                subscription = [[xs observeOn:scheduler] subscribe:observer];
                XCTAssert([xs.subscriptions isEqualToArray:@[RxSubscribedToHotObservable()]]);
                [xs onNext:@0];
                return subscription;
            },
            ^id <RxDisposable>(RxSerialDispatchQueueScheduler *scheduler) {
                BOOL b = [observer.events isEqualToArray:@[[self next:@0]]];
                XCTAssert(b);
                XCTAssert([xs.subscriptions isEqualToArray:@[RxSubscribedToHotObservable()]]);
                [subscription dispose];
                XCTAssert([xs.subscriptions isEqualToArray:@[RxUnsunscribedFromHotObservable()]]);

                [xs onError:[RxTestError testError]];

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
@end
