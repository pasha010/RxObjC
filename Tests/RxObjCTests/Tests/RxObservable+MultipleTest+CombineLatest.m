//
//  RxObservable+MultipleTest+CombineLatest.m
//  RxObjC
//
//  Created by Pavel Malkov on 10.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"

@interface RxObservableMultipleTestCombineLatest : RxTest
@end

@implementation RxObservableMultipleTestCombineLatest

- (void)_test_combineLatest_NeverN:(NSUInteger)n {
    NSAssert(n > 1, @"n < 2, n == %lu", n);

    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    NSMutableArray<RxTestableObservable *> *e = [NSMutableArray arrayWithCapacity:n];

    for (NSUInteger i = 0; i < n; i++) {
        RxTestableObservable *e0 = [scheduler createHotObservable:@[
                next(150, @1)
        ]];
        [e addObject:e0];
    }

    RxObservable *(^create)();

    switch (n) {
        case 2: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] resultSelector:^id(id o1, id o2) {
                    return @42;
                }];
            };

            break;
        }
        case 3: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] resultSelector:^id(id o1, id o2, id o3) {
                    return @42;
                }];
            };

            break;
        }

        case 4: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] resultSelector:^id(id o1, id o2, id o3, id o4) {
                    return @42;
                }];
            };
            break;
        }

        case 5: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] and:e[4] resultSelector:^id(id o1, id o2, id o3, id o4, id o5) {
                    return @42;
                }];
            };
            break;
        }

        case 6: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] and:e[4] and:e[5] resultSelector:^id(id o1, id o2, id o3, id o4, id o5, id o6) {
                    return @42;
                }];
            };
            break;
        }

        case 7: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] and:e[4] and:e[5] and:e[6] resultSelector:^id(id o1, id o2, id o3, id o4, id o5, id o6, id o7) {
                    return @42;
                }];
            };
            break;
        }

        case 8: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] and:e[4] and:e[5] and:e[6] and:e[7] resultSelector:^id(id o1, id o2, id o3, id o4, id o5, id o6, id o7, id o8) {
                    return @42;
                }];
            };
            break;
        }

        default:
            create = ^RxObservable * {
                return [RxObservable combineLatest:e resultSelector:^id(RxTuple *tuple) {
                    return @42;
                }];
            };
            break;
    }

    RxTestableObserver *res = [scheduler start:create];
    XCTAssertEqualObjects(res.events, @[]);
    int i = 0;
    for (RxTestableObservable *o in e) {
        XCTAssertEqualObjects(o.subscriptions, @[Subscription(200, 1000)], @"i = %d", i);
        i++;
    }
}

- (void)_testCombineLatest_EmptyN:(NSUInteger)n {
    NSAssert(n > 1, @"n < 2, n == %lu", n);

    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    NSMutableArray<RxTestableObservable *> *e = [NSMutableArray arrayWithCapacity:n];

    for (NSUInteger i = 0; i < n; i++) {
        RxTestableObservable *e0 = [scheduler createHotObservable:@[
                next(150, @1),
                completed(200 + (i + 1) * 10)
        ]];
        [e addObject:e0];
    }

    RxObservable *(^create)();
    switch (n) {
        case 2: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] resultSelector:^id(id o1, id o2) {
                    return @42;
                }];
            };

            break;
        }
        case 3: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] resultSelector:^id(id o1, id o2, id o3) {
                    return @42;
                }];
            };

            break;
        }

        case 4: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] resultSelector:^id(id o1, id o2, id o3, id o4) {
                    return @42;
                }];
            };
            break;
        }

        case 5: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] and:e[4] resultSelector:^id(id o1, id o2, id o3, id o4, id o5) {
                    return @42;
                }];
            };
            break;
        }

        case 6: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] and:e[4] and:e[5] resultSelector:^id(id o1, id o2, id o3, id o4, id o5, id o6) {
                    return @42;
                }];
            };
            break;
        }

        case 7: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] and:e[4] and:e[5] and:e[6] resultSelector:^id(id o1, id o2, id o3, id o4, id o5, id o6, id o7) {
                    return @42;
                }];
            };
            break;
        }

        case 8: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] and:e[4] and:e[5] and:e[6] and:e[7] resultSelector:^id(id o1, id o2, id o3, id o4, id o5, id o6, id o7, id o8) {
                    return @42;
                }];
            };
            break;
        }

        default:
            create = ^RxObservable * {
                return [RxObservable combineLatest:e resultSelector:^id(RxTuple *tuple) {
                    return @42;
                }];
            };
            break;
    }

    RxTestableObserver *res = [scheduler start:create];

    XCTAssertEqualObjects(res.events, @[completed(200 + 10 * n)]);
    int i = 0;
    for (RxTestableObservable *o in e) {
        XCTAssertEqualObjects(o.subscriptions, @[Subscription(200, 200 + (i + 1) * 10)], @"i = %d", i);
        i++;
    }
}

- (void)_testCombineLatest_SelectorThrowsN:(NSUInteger)n {
    NSAssert(n > 1, @"n < 2, n == %lu", n);

    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    NSMutableArray<RxTestableObservable *> *e = [NSMutableArray arrayWithCapacity:n];

    for (NSUInteger i = 0; i < n; i++) {
        RxTestableObservable *e0 = [scheduler createHotObservable:@[
                next(150, @1),
                next(200 + (i + 1) * 10, @1),
                completed(400)
        ]];
        [e addObject:e0];
    }

    RxObservable *(^create)();
    switch (n) {
        case 2: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] resultSelector:^id(id o1, id o2) {
                    @throw testError();
                }];
            };

            break;
        }
        case 3: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] resultSelector:^id(id o1, id o2, id o3) {
                    @throw testError();
                }];
            };

            break;
        }

        case 4: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] resultSelector:^id(id o1, id o2, id o3, id o4) {
                    @throw testError();
                }];
            };
            break;
        }

        case 5: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] and:e[4] resultSelector:^id(id o1, id o2, id o3, id o4, id o5) {
                    @throw testError();
                }];
            };
            break;
        }

        case 6: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] and:e[4] and:e[5] resultSelector:^id(id o1, id o2, id o3, id o4, id o5, id o6) {
                    @throw testError();
                }];
            };
            break;
        }

        case 7: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] and:e[4] and:e[5] and:e[6] resultSelector:^id(id o1, id o2, id o3, id o4, id o5, id o6, id o7) {
                    @throw testError();
                }];
            };
            break;
        }

        case 8: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] and:e[4] and:e[5] and:e[6] and:e[7] resultSelector:^id(id o1, id o2, id o3, id o4, id o5, id o6, id o7, id o8) {
                    @throw testError();
                }];
            };
            break;
        }

        default:
            create = ^RxObservable * {
                return [RxObservable combineLatest:e resultSelector:^id(RxTuple *tuple) {
                    @throw testError();
                }];
            };
            break;
    }

    RxTestableObserver *res = [scheduler start:create];

    XCTAssertEqualObjects(res.events, @[error(200 + (n * 10), testError())]);
    int i = 0;
    for (RxTestableObservable *o in e) {
        XCTAssertEqualObjects(o.subscriptions, @[Subscription(200, 200 + (10 * n))], @"i = %d", i);
        i++;
    }
}

- (void)_testCombineLatest_WillNeverBeAbleToCombineN:(NSUInteger)n {
    NSAssert(n > 1, @"n < 2, n == %lu", n);

    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    NSMutableArray<RxTestableObservable *> *e = [NSMutableArray arrayWithCapacity:n];

    for (NSUInteger i = 0; i < n; i++) {
        RxTestableObservable *e0;
        if (i != n - 1) {
            e0 = [scheduler createHotObservable:@[
                    next(150, @1),
                    completed(250 + i * 10)
            ]];
        } else {
            e0 = [scheduler createHotObservable:@[
                    next(150, @1),
                    next(500, @2),
                    completed(800)
            ]];
        }
        [e addObject:e0];
    }

    RxObservable *(^create)();
    switch (n) {
        case 2: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] resultSelector:^id(id o1, id o2) {
                    return @42;
                }];
            };

            break;
        }
        case 3: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] resultSelector:^id(id o1, id o2, id o3) {
                    return @42;
                }];
            };

            break;
        }

        case 4: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] resultSelector:^id(id o1, id o2, id o3, id o4) {
                    return @42;
                }];
            };
            break;
        }

        case 5: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] and:e[4] resultSelector:^id(id o1, id o2, id o3, id o4, id o5) {
                    return @42;
                }];
            };
            break;
        }

        case 6: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] and:e[4] and:e[5] resultSelector:^id(id o1, id o2, id o3, id o4, id o5, id o6) {
                    return @42;
                }];
            };
            break;
        }

        case 7: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] and:e[4] and:e[5] and:e[6] resultSelector:^id(id o1, id o2, id o3, id o4, id o5, id o6, id o7) {
                    return @42;
                }];
            };
            break;
        }

        case 8: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] and:e[4] and:e[5] and:e[6] and:e[7] resultSelector:^id(id o1, id o2, id o3, id o4, id o5, id o6, id o7, id o8) {
                    return @42;
                }];
            };
            break;
        }

        default:
            create = ^RxObservable * {
                return [RxObservable combineLatest:e resultSelector:^id(RxTuple *tuple) {
                    return @42;
                }];
            };
            break;
    }

    RxTestableObserver *res = [scheduler start:create];

    XCTAssertEqualObjects(res.events, @[completed(500)]);
    int i = 0;
    for (RxTestableObservable *o in e) {
        if (i != e.count - 1) {
            XCTAssertEqualObjects(o.subscriptions, @[Subscription(200, 250 + i * 10)], @"i = %d", i);
        } else {
            XCTAssertEqualObjects(o.subscriptions, @[Subscription(200, 500)], @"i = %d", i);
        }
        i++;
    }
}

- (void)_testCombineLatest_TypicalN:(NSUInteger)n {
    NSAssert(n > 1, @"n < 2, n == %lu", n);

    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    NSMutableArray<RxTestableObservable *> *e = [NSMutableArray arrayWithCapacity:n];

    for (NSUInteger i = 0; i < n; i++) {
        RxTestableObservable *e0 = [scheduler createHotObservable:@[
                next(150, @1),
                next(200 + 10 * (i + 1), @(i + 1)),
                next(400 + 10 * (i + 1), @(n + i + 1)),
                completed(800)
        ]];
        [e addObject:e0];
    }

    RxObservable *(^create)();
    switch (n) {
        case 2: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] resultSelector:^id(NSNumber *o1, NSNumber *o2) {
                    return @(o1.integerValue + o2.integerValue);
                }];
            };

            break;
        }
        case 3: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] resultSelector:^id(NSNumber *o1, NSNumber *o2, NSNumber *o3) {
                    return @(o1.integerValue + o2.integerValue + o3.integerValue);
                }];
            };

            break;
        }

        case 4: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] resultSelector:^id(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4) {
                    return @(o1.integerValue + o2.integerValue + o3.integerValue + o4.integerValue);
                }];
            };
            break;
        }

        case 5: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] and:e[4] resultSelector:^id(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5) {
                    return @(o1.integerValue + o2.integerValue + o3.integerValue + o4.integerValue + o5.integerValue);
                }];
            };
            break;
        }

        case 6: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] and:e[4] and:e[5] resultSelector:^id(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5, NSNumber *o6) {
                    return @(o1.integerValue + o2.integerValue + o3.integerValue + o4.integerValue + o5.integerValue + o6.integerValue);
                }];
            };
            break;
        }

        case 7: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] and:e[4] and:e[5] and:e[6] resultSelector:^id(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5, NSNumber *o6, NSNumber *o7) {
                    return @(o1.integerValue + o2.integerValue + o3.integerValue + o4.integerValue + o5.integerValue + o6.integerValue + o7.integerValue);
                }];
            };
            break;
        }

        case 8: {
            create = ^RxObservable * {
                return [RxObservable combineLatest:e[0] and:e[1] and:e[2] and:e[3] and:e[4] and:e[5] and:e[6] and:e[7] resultSelector:^id(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5, NSNumber *o6, NSNumber *o7, NSNumber *o8) {
                    return @(o1.integerValue + o2.integerValue + o3.integerValue + o4.integerValue + o5.integerValue + o6.integerValue + o7.integerValue + o8.integerValue);
                }];
            };
            break;
        }

        default:
            create = ^RxObservable * {
                return [RxObservable combineLatest:e resultSelector:^id(RxTuple *tuple) {
                    return [[tuple.array objectEnumerator] reduce:@0 combine:RxCombinePlus()];
                }];
            };
            break;
    }

    RxTestableObserver *res = [scheduler start:create];

    NSUInteger sum = 0;
    for (NSUInteger j = 1; j <= n; j++) {
        sum += j;
    }
    NSMutableArray *events = [@[next(200 + n * 10, @(sum))] mutableCopy];
    for (NSUInteger j = 1; j <= n; j++) {
        [events addObject:next(400 + 10 * j, @(sum + j * n))];
    }

    [events addObject:completed(800)];
    XCTAssertEqualObjects(res.events, events);

    int i = 0;
    for (RxTestableObservable *o in e) {
        XCTAssertEqualObjects(o.subscriptions, @[Subscription(200, 800)], @"i = %d", i);
        i++;
    }
}

#pragma mark - common

- (void)testCombineLatest_NeverEmpty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1)
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            completed(210)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    XCTAssertEqualObjects(res.events, @[]);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 1000)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 210)]);
}

- (void)testCombineLatest_EmptyNever {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
            completed(210)
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    XCTAssertEqualObjects(res.events, @[]);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 210)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 1000)]);
}

- (void)testCombineLatest_EmptyReturn {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
            completed(210)
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @2),
            completed(220)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    XCTAssertEqualObjects(res.events, @[completed(215)]);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 210)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 215)]);
}

- (void)testCombineLatest_ReturnEmpty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @2),
            completed(220)
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            completed(210)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    XCTAssertEqualObjects(res.events, @[completed(215)]);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 215)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 210)]);
}

- (void)testCombineLatest_NeverReturn {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @2),
            completed(220)
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    XCTAssertEqualObjects(res.events, @[]);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 220)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 1000)]);
}

- (void)testCombineLatest_ReturnNever {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @2),
            completed(220)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    XCTAssertEqualObjects(res.events, @[]);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 1000)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 220)]);
}

- (void)testCombineLatest_ReturnReturn1 {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @2),
            completed(230)
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(220, @3),
            completed(240)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    NSArray *events = @[
            next(220, @(2 + 3)),
            completed(240)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 230)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 240)]);
}

- (void)testCombineLatest_ReturnReturn2 {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
            next(220, @3),
            completed(240)
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @2),
            completed(230)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    NSArray *events = @[
            next(220, @(2 + 3)),
            completed(240)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 240)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 230)]);
}

- (void)testCombineLatest_EmptyError {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
            completed(230)
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            error(220, testError())
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    NSArray *events = @[
            error(220, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 220)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 220)]);
}

- (void)testCombineLatest_ErrorEmpty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
            error(220, testError())
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            completed(230)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    NSArray *events = @[
            error(220, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 220)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 220)]);
}

- (void)testCombineLatest_ReturnThrow {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            completed(230)
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            error(220, testError())
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    NSArray *events = @[
            error(220, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 220)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 220)]);
}

- (void)testCombineLatest_ThrowReturn {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
            error(220, testError())
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            completed(230)

    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    NSArray *events = @[
            error(220, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 220)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 220)]);
}

- (void)testCombineLatest_ThrowThrow1 {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
            error(220, testError1()),
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            error(230, testError2()),

    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    NSArray *events = @[
            error(220, testError1())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 220)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 220)]);
}

- (void)testCombineLatest_ThrowThrow2 {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
            error(230, testError1()),
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            error(220, testError2()),

    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    NSArray *events = @[
            error(220, testError2())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 220)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 220)]);
}

- (void)testCombineLatest_ErrorThrow {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            error(220, testError1()),
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            error(230, testError2()),

    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    NSArray *events = @[
            error(220, testError1())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 220)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 220)]);
}

- (void)testCombineLatest_ThrowError {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
            error(230, testError2()),
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            error(220, testError1())

    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    NSArray *events = @[
            error(220, testError1())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 220)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 220)]);
}

- (void)testCombineLatest_SomeThrow {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @2),
            completed(230)
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            error(220, testError()),

    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    NSArray *events = @[
            error(220, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 220)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 220)]);
}

- (void)testCombineLatest_ThrowSome {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
            error(220, testError()),
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @2),
            completed(230)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    NSArray *events = @[
            error(220, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 220)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 220)]);
}

- (void)testCombineLatest_ThrowAfterCompleteLeft {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @2),
            completed(220)
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            error(230, testError())
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    NSArray *events = @[
            error(230, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 220)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 230)]);
}

- (void)testCombineLatest_ThrowAfterCompleteRight {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
            error(230, testError()),
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @2),
            completed(220)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    NSArray *events = @[
            error(230, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 230)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 220)]);
}

- (void)testCombineLatest_TestInterleavedWithTail {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @2),
            next(225, @4),
            completed(230)
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(220, @3),
            next(230, @5),
            next(235, @6),
            next(240, @7),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    NSArray *events = @[
            next(220, @(2 + 3)),
            next(225, @(3 + 4)),
            next(230, @(4 + 5)),
            next(235, @(4 + 6)),
            next(240, @(4 + 7)),
            completed(250)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 230)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 250)]);
}

- (void)testCombineLatest_Consecutive {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @2),
            next(225, @4),
            completed(230)
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(235, @6),
            next(240, @7),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    NSArray *events = @[
            next(235, @(4 + 6)),
            next(240, @(4 + 7)),
            completed(250)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 230)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 250)]);
}

- (void)testCombineLatest_ConsecutiveEndWithErrorLeft {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @2),
            next(225, @4),
            error(230, testError())
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(235, @6),
            next(240, @7),
            completed(250)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    NSArray *events = @[
            error(230, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 230)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 230)]);
}

- (void)testCombineLatest_ConsecutiveEndWithErrorRight {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *e0 = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @2),
            next(225, @4),
            completed(250)
    ]];

    RxTestableObservable *e1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(235, @6),
            next(240, @7),
            error(245, testError())
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable combineLatest:e0 and:e1 resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
            return @(o1.integerValue + o2.integerValue);
        }];
    }];

    NSArray *events = @[
            next(235, @(4 + 6)),
            next(240, @(4 + 7)),
            error(245, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(e0.subscriptions, @[Subscription(200, 245)]);
    XCTAssertEqualObjects(e1.subscriptions, @[Subscription(200, 245)]);
}

@end

@implementation RxObservableMultipleTestCombineLatest (With2)

- (void)testCombineLatest_Never2 {
    [self _test_combineLatest_NeverN:2];
}

- (void)testCombineLatest_Empty2 {
    [self _testCombineLatest_EmptyN:2];
}

- (void)testCombineLatest_SelectorThrows2 {
    [self _testCombineLatest_SelectorThrowsN:2];
}

- (void)testCombineLatest_WillNeverBeAbleToCombine2 {
    [self _testCombineLatest_WillNeverBeAbleToCombineN:2];
}

- (void)testCombineLatest_Typical2 {
    [self _testCombineLatest_TypicalN:2];
}

@end

@implementation RxObservableMultipleTestCombineLatest (With3)

- (void)testCombineLatest_Never3 {
    [self _test_combineLatest_NeverN:3];
}

- (void)testCombineLatest_Empty3 {
    [self _testCombineLatest_EmptyN:3];
}

- (void)testCombineLatest_SelectorThrows3 {
    [self _testCombineLatest_SelectorThrowsN:3];
}

- (void)testCombineLatest_WillNeverBeAbleToCombine3 {
    [self _testCombineLatest_WillNeverBeAbleToCombineN:3];
}

- (void)testCombineLatest_Typical3 {
    [self _testCombineLatest_TypicalN:3];
}

@end

@implementation RxObservableMultipleTestCombineLatest (With4)

- (void)testCombineLatest_Never4 {
    [self _test_combineLatest_NeverN:4];
}

- (void)testCombineLatest_Empty4 {
    [self _testCombineLatest_EmptyN:4];
}

- (void)testCombineLatest_SelectorThrows4 {
    [self _testCombineLatest_SelectorThrowsN:4];
}

- (void)testCombineLatest_WillNeverBeAbleToCombine4 {
    [self _testCombineLatest_WillNeverBeAbleToCombineN:4];
}

- (void)testCombineLatest_Typical4 {
    [self _testCombineLatest_TypicalN:4];
}

@end

@implementation RxObservableMultipleTestCombineLatest (With5)

- (void)testCombineLatest_Never5 {
    [self _test_combineLatest_NeverN:5];
}

- (void)testCombineLatest_Empty5 {
    [self _testCombineLatest_EmptyN:5];
}

- (void)testCombineLatest_SelectorThrows5 {
    [self _testCombineLatest_SelectorThrowsN:5];
}

- (void)testCombineLatest_WillNeverBeAbleToCombine5 {
    [self _testCombineLatest_WillNeverBeAbleToCombineN:5];
}

- (void)testCombineLatest_Typical5 {
    [self _testCombineLatest_TypicalN:5];
}

@end

@implementation RxObservableMultipleTestCombineLatest (With6)

- (void)testCombineLatest_Never6 {
    [self _test_combineLatest_NeverN:6];
}

- (void)testCombineLatest_Empty6 {
    [self _testCombineLatest_EmptyN:6];
}

- (void)testCombineLatest_SelectorThrows6 {
    [self _testCombineLatest_SelectorThrowsN:6];
}

- (void)testCombineLatest_WillNeverBeAbleToCombine6 {
    [self _testCombineLatest_WillNeverBeAbleToCombineN:6];
}

- (void)testCombineLatest_Typical6 {
    [self _testCombineLatest_TypicalN:6];
}

@end

@implementation RxObservableMultipleTestCombineLatest (With7)

- (void)testCombineLatest_Never7 {
    [self _test_combineLatest_NeverN:7];
}

- (void)testCombineLatest_Empty7 {
    [self _testCombineLatest_EmptyN:7];
}

- (void)testCombineLatest_SelectorThrows7 {
    [self _testCombineLatest_SelectorThrowsN:7];
}

- (void)testCombineLatest_WillNeverBeAbleToCombine7 {
    [self _testCombineLatest_WillNeverBeAbleToCombineN:7];
}

- (void)testCombineLatest_Typical7 {
    [self _testCombineLatest_TypicalN:7];
}

@end

@implementation RxObservableMultipleTestCombineLatest (With8)

- (void)testCombineLatest_Never8 {
    [self _test_combineLatest_NeverN:8];
}

- (void)testCombineLatest_Empty8 {
    [self _testCombineLatest_EmptyN:8];
}

- (void)testCombineLatest_SelectorThrows8 {
    [self _testCombineLatest_SelectorThrowsN:8];
}

- (void)testCombineLatest_WillNeverBeAbleToCombine8 {
    [self _testCombineLatest_WillNeverBeAbleToCombineN:8];
}

- (void)testCombineLatest_Typical8 {
    [self _testCombineLatest_TypicalN:8];
}

@end

@implementation RxObservableMultipleTestCombineLatest (With12)

- (void)testCombineLatest_Never12 {
    [self _test_combineLatest_NeverN:12];
}

- (void)testCombineLatest_Empty12 {
    [self _testCombineLatest_EmptyN:12];
}

- (void)testCombineLatest_SelectorThrows12 {
    [self _testCombineLatest_SelectorThrowsN:12];
}

- (void)testCombineLatest_WillNeverBeAbleToCombine12 {
    [self _testCombineLatest_WillNeverBeAbleToCombineN:12];
}

- (void)testCombineLatest_Typical12 {
    [self _testCombineLatest_TypicalN:12];
}

@end
