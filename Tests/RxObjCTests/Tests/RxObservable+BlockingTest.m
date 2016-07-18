//
//  RxObservable+BlockingTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 10.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"
#import "RxTestError.h"

@interface RxObservableBlockingTest : RxTest

@end

@implementation RxObservableBlockingTest
@end

@implementation RxObservableBlockingTest (ToArray)

- (void)testToArray_empty {
    XCTAssert([[[[RxObservable empty] toBlocking] blocking_toArray] isEqualToArray:@[]]);
}

- (void)testToArray_return {
    XCTAssert([[[[RxObservable just:@42] toBlocking] blocking_toArray] isEqualToArray:@[@42]]);
}

- (void)testToArray_fail {
    rx_tryCatch(^{
        [[[RxObservable error:[RxTestError testError]] toBlocking] blocking_toArray];
        XCTFail(@"It should fail");
    }, ^(NSError *error) {
        XCTAssert([error isEqual:[RxTestError testError]]);
    });
}

- (void)testToArray_someData {
    BOOL b = [[[[RxObservable of:@[@42, @43, @44, @45]] toBlocking] blocking_toArray] isEqualToArray:@[@42, @43, @44, @45]];
    XCTAssert(b);
}

- (void)testToArray_withRealScheduler {
    RxConcurrentDispatchQueueScheduler *scheduler = [[RxConcurrentDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOS:[RxDispatchQueueSchedulerQOS default]];

    NSArray<NSNumber *> *array = [[[[RxObservable interval:0.001 scheduler:scheduler]
            take:10] 
            toBlocking]
            blocking_toArray];
    
    NSMutableArray<NSNumber *> *numbers = [NSMutableArray arrayWithCapacity:10];
    for (NSUInteger i = 0; i < 10; i++) {
        [numbers addObject:@(i)];
    }
    XCTAssert([array isEqualToArray:numbers]);
}

- (void)testToArray_independent {
    for (NSUInteger i = 0; i < 10; i++) {
        RxConcurrentDispatchQueueScheduler *scheduler = [[RxConcurrentDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOS:[RxDispatchQueueSchedulerQOS default]];

        RxObservable<NSNumber *> *(^operation1)() = ^{
            return [[RxObservable of:@[@1, @2]] subscribeOn:scheduler];
        };

        NSArray<NSNumber *> *a = [[operation1() toBlocking] blocking_toArray];
        NSArray<NSNumber *> *b = [[operation1() toBlocking] blocking_toArray];
        NSArray<NSNumber *> *c = [[operation1() toBlocking] blocking_toArray];
        NSArray<NSNumber *> *d = [[operation1() toBlocking] blocking_toArray];

        NSArray<NSNumber *> *n = @[@1, @2];
        XCTAssertEqualObjects(a, n);
        XCTAssertEqualObjects(b, n);
        XCTAssertEqualObjects(c, n);
        XCTAssertEqualObjects(d, n);
    }
}
@end

@implementation RxObservableBlockingTest (First)

- (void)testFirst_empty {
    XCTAssert([[[RxObservable empty] toBlocking] blocking_first] == nil);
}

- (void)testFirst_return {
    XCTAssert([[[[RxObservable just:@42] toBlocking] blocking_first] isEqualToNumber:@42]);
}

- (void)testFirst_fail {
    rx_tryCatch(^{
        [[[RxObservable error:[RxTestError testError]] toBlocking] blocking_first];
        XCTFail(@"");
    }, ^(NSError *error) {
        XCTAssert([error isEqual:[RxTestError testError]]);
    });
}

- (void)testFirst_someData {
    BOOL b = [[[[RxObservable of:@[@42, @43, @44, @45]] toBlocking] blocking_first] isEqualToNumber:@42];
    XCTAssert(b);
}

- (void)testFirst_withRealScheduler {
    RxConcurrentDispatchQueueScheduler *scheduler = [[RxConcurrentDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOS:[RxDispatchQueueSchedulerQOS default]];

    NSNumber *v = [[[[RxObservable interval:0.001 scheduler:scheduler]
            take:10]
            toBlocking]
            blocking_first];

    XCTAssert([v isEqualToNumber:@0]);
}

- (void)testFirst_independent {
    for (NSUInteger i = 0; i < 10; i++) {
        RxConcurrentDispatchQueueScheduler *scheduler = [[RxConcurrentDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOS:[RxDispatchQueueSchedulerQOS default]];

        RxObservable<NSNumber *> *(^operation1)() = ^{
            return [[RxObservable just:@1] subscribeOn:scheduler];
        };

        NSNumber *a = [[operation1() toBlocking] blocking_first];
        NSNumber *b = [[operation1() toBlocking] blocking_first];
        NSNumber *c = [[operation1() toBlocking] blocking_first];
        NSNumber *d = [[operation1() toBlocking] blocking_first];

        XCTAssertEqualObjects(a, @1);
        XCTAssertEqualObjects(b, @1);
        XCTAssertEqualObjects(c, @1);
        XCTAssertEqualObjects(d, @1);
    }
}
@end

@implementation RxObservableBlockingTest (Last)

- (void)testLast_empty {
    XCTAssert([[[RxObservable empty] toBlocking] blocking_last] == nil);
}

- (void)testLast_return {
    XCTAssert([[[[RxObservable just:@42] toBlocking] blocking_last] isEqualToNumber:@42]);
}

- (void)testLast_fail {
    rx_tryCatch(^{
        [[[RxObservable error:[RxTestError testError]] toBlocking] blocking_last];
        XCTFail(@"");
    }, ^(NSError *error) {
        XCTAssert([error isEqual:[RxTestError testError]]);
    });
}

- (void)testLast_someData {
    BOOL b = [[[[RxObservable of:@[@42, @43, @44, @45]] toBlocking] blocking_last] isEqualToNumber:@45];
    XCTAssert(b);
}

- (void)testLast_withRealScheduler {
    RxConcurrentDispatchQueueScheduler *scheduler = [[RxConcurrentDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOS:[RxDispatchQueueSchedulerQOS default]];

    NSNumber *v = [[[[RxObservable interval:0.001 scheduler:scheduler]
            take:10]
            toBlocking]
            blocking_last];

    XCTAssert([v isEqualToNumber:@9]);
}

- (void)testLast_independent {
    for (NSUInteger i = 0; i < 10; i++) {
        RxConcurrentDispatchQueueScheduler *scheduler = [[RxConcurrentDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOS:[RxDispatchQueueSchedulerQOS default]];

        RxObservable<NSNumber *> *(^operation1)() = ^{
            return [[RxObservable just:@1] subscribeOn:scheduler];
        };

        NSNumber *a = [[operation1() toBlocking] blocking_last];
        NSNumber *b = [[operation1() toBlocking] blocking_last];
        NSNumber *c = [[operation1() toBlocking] blocking_last];
        NSNumber *d = [[operation1() toBlocking] blocking_last];

        XCTAssertEqualObjects(a, @1);
        XCTAssertEqualObjects(b, @1);
        XCTAssertEqualObjects(c, @1);
        XCTAssertEqualObjects(d, @1);
    }
}
@end

@implementation RxObservableBlockingTest (Single)

- (void)testSingle_empty {
    rx_tryCatch(^{
        [[[RxObservable empty] toBlocking] blocking_single];
        XCTFail(@"");
    }, ^(NSError *e) {
        RxError *error = (RxError *)e;
        XCTAssert(error.code == RxError.noElements.code);
    });
}

- (void)testSingle_return {
    XCTAssert([[[[RxObservable just:@42] toBlocking] blocking_single] isEqualToNumber:@42]);
}

- (void)testSingle_two {
    NSArray *array = @[@42, @43];
    rx_tryCatch(^{
        [[[RxObservable of:array] toBlocking] blocking_single];
    }, ^(NSError *e) {
        RxError *error = (RxError *)e;
        XCTAssert(error.code == [RxError moreThanOneElement].code);
    });
}

- (void)testSingle_someData {
    NSArray *array = @[@42, @43, @44, @45];
    rx_tryCatch(^{
        [[[RxObservable of:array] toBlocking] blocking_single];
        XCTFail(@"");
    }, ^(NSError *e) {
        RxError *error = (RxError *)e;
        XCTAssert(error.code == [RxError moreThanOneElement].code);
    });
}

- (void)testSingle_fail {
    rx_tryCatch(^{
       [[[RxObservable error:[RxTestError testError]] toBlocking] blocking_single]; 
    }, ^(NSError *error) {
        XCTAssert([error isEqual:[RxTestError testError]]);
    });
}

- (void)testSingle_withRealScheduler {
    RxConcurrentDispatchQueueScheduler *scheduler = [[RxConcurrentDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOS:[RxDispatchQueueSchedulerQOS default]];

    NSNumber *obj = [[[[RxObservable interval:0.001 scheduler:scheduler]
            take:1]
            toBlocking]
            blocking_single];
    
    XCTAssert([obj isEqualToNumber:@0]);
}

- (void)testSingle_predicate_empty {
    rx_tryCatch(^{
        [[[RxObservable empty] toBlocking] blocking_single:^BOOL(id o) {
            return YES;
        }];
        XCTFail(@"");
    }, ^(NSError *e) {
        RxError *error = (RxError *)e;
        XCTAssert(error.code == [RxError noElements].code);
    });
}

- (void)testSingle_predicate_return {
    XCTAssert([[[[RxObservable just:@42] toBlocking] blocking_single:^BOOL(id o) {
        return YES;
    }] isEqualToNumber:@42]);
}

- (void)testSingle_predicate_someData_one_match {
    NSMutableArray<NSNumber *> *predicateVals = [NSMutableArray array];
    
    @try {
        [[[RxObservable of:@[@42, @43, @44, @45]] toBlocking] blocking_single:^BOOL(NSNumber *e) {
            [predicateVals addObject:e];;
            return [e isEqualToNumber:@44];
        }];
    } 
    @catch(id _) {
        XCTFail(@"");
    }

    NSArray *array = @[@42, @43, @44, @45];
    XCTAssert([predicateVals isEqualToArray:array]);
}

- (void)testSingle_predicate_someData_two_match {
    NSMutableArray<NSNumber *> *predicateVals = [NSMutableArray array];

    NSArray *array1 = @[@42, @43, @44, @45];
    rx_tryCatch(^{
        [[[RxObservable of:array1] toBlocking] blocking_single:^BOOL(NSNumber *element) {
            [predicateVals addObject:element];
            return element.integerValue >= 43;
        }];
        XCTFail(@"");
    }, ^(NSError *e) {
        RxError *error = (RxError *)e;
        XCTAssert(error.code == [RxError moreThanOneElement].code);
    });

    NSArray *array = @[@42, @43, @44];
    XCTAssert([predicateVals isEqualToArray:array]);
}

- (void)testSingle_predicate_none {
    NSMutableArray<NSNumber *> *predicateVals = [NSMutableArray array];

    NSArray *array1 = @[@42, @43, @44, @45];
    rx_tryCatch(^{
        [[[RxObservable of:array1] toBlocking] blocking_single:^BOOL(NSNumber *element) {
            [predicateVals addObject:element];
            return element.integerValue > 50;
        }];
        XCTFail(@"");
    }, ^(NSError *e) {
        RxError *error = (RxError *)e;
        XCTAssert(error.code == [RxError noElements].code);
    });

    NSArray *array = @[@42, @43, @44, @45];
    XCTAssert([predicateVals isEqualToArray:array]);
}

- (void)testSingle_predicate_throws {
    NSMutableArray<NSNumber *> *predicateVals = [NSMutableArray array];

    NSArray *array1 = @[@42, @43, @44, @45];
    rx_tryCatch(^{
        [[[RxObservable of:array1 scheduler:[RxCurrentThreadScheduler sharedInstance]] toBlocking] blocking_single:^BOOL(NSNumber *element) {
            [predicateVals addObject:element];
            if (element.integerValue < 43) {
                return NO;
            }
            @throw [RxTestError testError];
        }];
        XCTFail(@"");
    }, ^(NSError *e) {
        XCTAssert([e isEqual:[RxTestError testError]]);
    });

    NSArray *array = @[@42, @43];
    XCTAssert([predicateVals isEqualToArray:array]);
}

- (void)testSingle_predicate_fail {
    rx_tryCatch(^{
        [[[RxObservable error:[RxTestError testError]] toBlocking] blocking_single:^BOOL(id o) {
            return YES;
        }];
        XCTFail(@"");
    }, ^(NSError *error) {
        XCTAssert([error isEqual:[RxTestError testError]]);
    });
}

- (void)testSingle_predicate_withRealScheduler {
    RxConcurrentDispatchQueueScheduler *scheduler = [[RxConcurrentDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOS:[RxDispatchQueueSchedulerQOS default]];

    NSNumber *obj = [[[[RxObservable interval:0.001 scheduler:scheduler]
            take:4] 
            toBlocking] 
            blocking_single:^BOOL(NSNumber *n) {
                return n.integerValue == 3;
            }];
    XCTAssert(obj.integerValue == 3);
}

- (void)testSingle_independent {
    for (NSUInteger i = 0; i < 10; i++) {
        RxConcurrentDispatchQueueScheduler *scheduler = [[RxConcurrentDispatchQueueScheduler alloc] initWithGlobalConcurrentQueueQOS:[RxDispatchQueueSchedulerQOS default]];

        RxObservable<NSNumber *> *(^operation1)() = ^{
            return [[RxObservable just:@1] subscribeOn:scheduler];
        };

        NSNumber *a = [[operation1() toBlocking] blocking_single];
        NSNumber *b = [[operation1() toBlocking] blocking_single];
        NSNumber *c = [[operation1() toBlocking] blocking_single];
        NSNumber *d = [[operation1() toBlocking] blocking_single];

        XCTAssertEqualObjects(a, @1);
        XCTAssertEqualObjects(b, @1);
        XCTAssertEqualObjects(c, @1);
        XCTAssertEqualObjects(d, @1);
    }
}
@end