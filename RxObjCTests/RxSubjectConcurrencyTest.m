//
//  RxSubjectConcurrencyTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RxTest.h"
#import "RxPublishSubject.h"
#import "RxTuple.h"
#import "RxAnyObserver.h"
#import "RxMutableBox.h"

@interface RxSubjectConcurrencyTest : RxTest

@end

@implementation RxSubjectConcurrencyTest

- (RxTuple *)createSubject {
    RxPublishSubject<NSNumber *> *subject = [RxPublishSubject create];
    return [RxTuple tupleWithArray:@[subject.asObservable, [[RxAnyObserver alloc] initWithEventHandler:^(RxEvent<NSNumber *> *event) {
        [[subject asObservable] on:event];
    }]]];
}
@end

@implementation RxSubjectConcurrencyTest (Test)

- (void)testSubjectIsSynchronized {
    RxTuple *tuple = [self createSubject];
    __block RxObservable<NSNumber *> *observable = tuple[0];
    __block RxAnyObserver<NSNumber *> *_observer = tuple[1];

    __block RxMutableBox *o = [[RxMutableBox alloc] initWithValue:_observer];

    __block BOOL allDone = NO;

    __block int state = 0;

    id <RxDisposable> _ = [observable subscribeNext:^(NSNumber *__nonnull n) {
        if (n.unsignedIntegerValue < 0) {
            return;
        }
        if (state == 0) {
            state = 1;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [o.value on:[RxEvent next:@1]];
            });

            // if other thread can't fulfill the condition in 0.5 sek, that means it is synchronized
            [NSThread sleepForTimeInterval:0.5];

            XCTAssertEqual(state, 1);

            dispatch_async(dispatch_get_main_queue(), ^{
                [o.value on:[RxEvent next:@2]];
            });
        } else if (state == 1) {
            XCTAssertTrue(![NSThread currentThread].isMainThread);
            state = 2;
        } else if (state == 2) {
            XCTAssertTrue([NSThread currentThread].isMainThread);
            allDone = YES;
        }
    }];

    [_observer on:[RxEvent next:@0]];

    // wait for second

    for (int i = 0; i < 1; i++) {
        [[NSRunLoop currentRunLoop] runUntilDate:[[NSDate date] dateByAddingTimeInterval:0.1]];
        if (allDone) {
            break;
        }
    }
    XCTAssertTrue(allDone);
}

// TODO complete this!

@end
