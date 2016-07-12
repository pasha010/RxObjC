//
//  RxVariableTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 10.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"
#import "RxVariable.h"
#import "RxObservable+CombineLatest.h"
#import "RxObservable+Extension.h"

@interface RxVariableTest : RxTest

@end

@implementation RxVariableTest

- (void)testVariable_initialValues {
    RxVariable *a = [RxVariable create:@1]; 
    RxVariable *b = [RxVariable create:@2];

    RxObservable<NSNumber *> *c = [RxObservable combineLatest:[a asObservable] and:[b asObservable] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
        return @(o1.integerValue + o2.integerValue);
    }];
    
    __block NSNumber *latestValue = nil;

    id <RxDisposable> subscription = [c subscribeNext:^(NSNumber *next) {
        latestValue = next;
    }];
    
    XCTAssertTrue(latestValue.integerValue == 3);
    
    a.value = @5;
    
    XCTAssertTrue(latestValue.integerValue == 7);
    
    b.value = @9;
    
    XCTAssertTrue(latestValue.integerValue == 14);

    [subscription dispose];
    
    a.value = @10;

    XCTAssertTrue(latestValue.integerValue == 14);
}

- (void)testVariable_sendsCompletedOnDealloc {
#if (__LP64__)  ||  (__ARM_ARCH_7K__ >= 2)
#define ENABLE_AUTORELEASE_FOR_COMPLETED_ON_DEALLOC 0
#else
#define ENABLE_AUTORELEASE_FOR_COMPLETED_ON_DEALLOC 1
    NSLog(@"it's 32 bit arch");
#endif

#if ENABLE_AUTORELEASE_FOR_COMPLETED_ON_DEALLOC
    __block NSNumber *latest = @0;
    __block BOOL completed = NO;
    @autoreleasepool {
#endif
        RxVariable<NSNumber *> *a = [RxVariable create:@1];

#if !ENABLE_AUTORELEASE_FOR_COMPLETED_ON_DEALLOC
        __block NSNumber *latest = @0;
        __block BOOL completed = NO;
#endif

        [[a asObservable] subscribeOnNext:^(NSNumber *n) {
            latest = n;
        } onCompleted:^{
            completed = YES;
        }];

        XCTAssertTrue(latest.integerValue == 1);
        XCTAssertFalse(completed);

        a = [RxVariable create:@2];

        XCTAssertTrue(latest.integerValue == 1);
#if ENABLE_AUTORELEASE_FOR_COMPLETED_ON_DEALLOC
    }
#endif

    XCTAssertTrue(completed);
}

- (void)testVariable_READMEExample {
    // Two simple Rx variables
    // Every variable is actually a sequence future values in disguise.
    RxVariable<NSNumber *> *a = [RxVariable create:@1];
    RxVariable<NSNumber *> *b = [RxVariable create:@2];

    // Computed third variable (or sequence)
    RxObservable<NSNumber *> *c = [RxObservable combineLatest:[a asObservable] and:[b asObservable] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
        return @(o1.integerValue + o2.integerValue);
    }];
    
    // Reading elements from c.
    // This is just a demo example.
    // Sequence elements are usually never enumerated like this.
    // Sequences are usually combined using map/filter/combineLatest ...
    //
    // This will immediatelly print:
    //      Next value of c = 3
    // because variables have initial values (starting element)
    
    __block NSNumber *latestValueOfC = nil;
    id <RxDisposable> d = [c subscribeNext:^(NSNumber *n) {
        NSLog(@"Next value of c = %@", n);
        latestValueOfC = n;
    }];

    XCTAssertTrue(latestValueOfC.integerValue == 3);

    a.value = @3;

    XCTAssertTrue(latestValueOfC.integerValue == 5);

    b.value = @5;

    XCTAssertTrue(latestValueOfC.integerValue == 8);

    [d dispose];
}

@end
