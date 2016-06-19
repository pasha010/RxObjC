//
//  RxBagTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 19.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RxBag.h"
#import "RxMutableBox.h"
#import "RxTest.h"
#import "RxAnyObserver.h"
#import "RxAnonymousDisposable.h"

@interface RxBagTest : RxTest

@end

typedef void (^RxDoSomething)();

@implementation RxBagTest

- (BOOL)accumulateStatistics {
    return NO;
}

- (void)numberOfActions:(NSUInteger)nInsertions
     deletionsFromStart:(NSUInteger)deletionsFromStart
              createNew:(id (^)())createNew
              bagAction:(void (^)(RxMutableBox<RxBag <id> *> *__nonnull))bagAction {

    RxMutableBox<RxBag <id> *> *bag = [[RxMutableBox alloc] initWithValue:[[RxBag alloc] init]];

    NSMutableArray<RxBagKey *> *keys = [NSMutableArray array];

    for (NSUInteger i = 0; i < nInsertions; i++) {
        RxBagKey *key = [bag.value insert:createNew()];
        [keys addObject:key];
    }

    for (NSUInteger i = 0; i < deletionsFromStart; i++) {
        RxBagKey *key = keys[i];
        XCTAssertTrue([bag.value removeKey:key] != nil);
    }
    bagAction(bag);
}

- (void)testBag_deletionsFromStart {
    for (NSUInteger i = 0; i < 50; i++) {
        for (NSUInteger j = 0; j <= i; j++) {
            __block NSUInteger numberForEachActions = 0;
            __block NSUInteger numberObservers = 0;
            __block NSUInteger numberDisposables = 0;

            [self numberOfActions:i
               deletionsFromStart:j
                        createNew:(id (^)()) ^RxDoSomething {
                            return ^{
                                numberForEachActions += 1;
                            };
                        }
                        bagAction:^(RxMutableBox<RxBag<RxDoSomething> *> *bag) {
                            [bag.value forEach:(void (^)(id)) ^(RxDoSomething doSomething) {
                                doSomething();
                            }];
                            XCTAssertTrue(bag.value.count == i - j);
                        }];

            [self numberOfActions:i
               deletionsFromStart:j
                        createNew:^RxAnyObserver * {
                            return [[RxAnyObserver alloc] initWithEventHandler:^(RxEvent *event) {
                                numberObservers += 1;
                            }];
                        }
                        bagAction:^(RxMutableBox<RxBag <RxAnyObserver <NSNumber *> *> *> *bag) {
                            [bag.value on:[RxEvent next:@1]];
                            XCTAssertTrue(bag.value.count == i - j);
                        }];

            [self numberOfActions:i
               deletionsFromStart:j
                        createNew:^RxAnonymousDisposable * {
                            return [[RxAnonymousDisposable alloc] initWithDisposeAction:^{
                                numberDisposables += 1;
                            }];
                        }
                        bagAction:^(RxMutableBox<RxBag<id <RxDisposable>> *> *bag) {
                            rx_disposeAllInBag(bag.value);
                            XCTAssertTrue(bag.value.count == i - j);
                        }];

            XCTAssertTrue(numberForEachActions == i - j, @"numberForEachActions = %d i = %d j = %d", numberForEachActions, i, j);
            XCTAssertTrue(numberObservers == i - j, @"numberObservers = %d i = %d j = %d", numberObservers, i, j);
            XCTAssertTrue(numberDisposables == i - j, @"numberDisposables = %d i = %d j = %d", numberDisposables, i, j);
        }
    }
}

- (void)testBag_immutableForeach {
    for (NSUInteger breakAt = 0; breakAt < 50; breakAt++) {
        __block NSUInteger increment1 = 0;
        __block NSUInteger increment2 = 0;
        __block NSUInteger increment3 = 0;

        RxMutableBox<RxBag<RxDoSomething> *> *bag1 = [[RxMutableBox alloc] initWithValue:[[RxBag alloc] init]];
        RxMutableBox<RxBag<RxAnyObserver <NSNumber *> *> *> *bag2 = [[RxMutableBox alloc] initWithValue:[[RxBag alloc] init]];
        RxMutableBox<RxBag<id <RxDisposable>> *> *bag3 = [[RxMutableBox alloc] initWithValue:[[RxBag alloc] init]];

        for (NSUInteger i = 0; i < 50; i++) {
            [bag1.value insert:^{
                if (increment1 == breakAt) {
                    [bag1.value removeAll];
                }
                increment1 += 1;
            }];

            [bag2.value insert:[[RxAnyObserver alloc] initWithEventHandler:^(RxEvent *event) {
                if (increment2 == breakAt) {
                    [bag2.value removeAll];
                }
                increment2 += 1;
            }]];

            [bag3.value insert:[[RxAnonymousDisposable alloc] initWithDisposeAction:^{
                if (increment3 == breakAt) {
                    [bag3.value removeAll];
                }
                increment3 += 1;
            }]];
        }

        for (NSUInteger j = 0; j < 2; j++) {
            [bag1.value forEach:^(RxDoSomething doSomething) {
                doSomething();
            }];
            [bag2.value on:[RxEvent next:@1]];

            rx_disposeAllInBag(bag3.value);
        }

        XCTAssertEqual(increment1, 50);
    }
}

@end
