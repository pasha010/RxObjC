//
//  RxObservable+MultipleTest+Zip.m
//  RxObjC
//
//  Created by Pavel Malkov on 10.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"

@interface RxObservableMultipleTestZip : RxTest

@end

@implementation RxObservableMultipleTestZip

- (void)_testZip_ImmediateScheduleN:(NSUInteger)n {
    NSAssert(n > 1, @"n < 2, n == %lu", n);

    NSMutableArray<RxObservable *> *v = [NSMutableArray arrayWithCapacity:n];
    for (NSUInteger i = 0; i < n; i++) {
        [v addObject:[RxObservable just:@(i + 1)]];
    }

    __block NSNumber *result = nil;

    RxObservable *observable;
    switch (n) {
        case 2: {
            observable = [RxObservable zip:v[0] and:v[1] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
                return @(o1.integerValue + o2.integerValue);
            }];
            break;
        }
        case 3: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3) {
                return @(o1.integerValue + o2.integerValue + o3.integerValue);
            }];
            break;
        }
        case 4: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4) {
                return @(o1.integerValue + o2.integerValue + o3.integerValue + o4.integerValue);
            }];
            break;
        }
        case 5: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] and:v[4] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5) {
                return @(o1.integerValue + o2.integerValue + o3.integerValue + o4.integerValue + o5.integerValue);
            }];
            break;
        }
        case 6: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] and:v[4] and:v[5] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5, NSNumber *o6) {
                return @(o1.integerValue + o2.integerValue + o3.integerValue + o4.integerValue + o5.integerValue + o6.integerValue);
            }];
            break;
        }
        case 7: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] and:v[4] and:v[5] and:v[6] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5, NSNumber *o6, NSNumber *o7) {
                return @(o1.integerValue + o2.integerValue + o3.integerValue + o4.integerValue + o5.integerValue + o6.integerValue + o7.integerValue);
            }];
            break;
        }
        case 8: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] and:v[4] and:v[5] and:v[6] and:v[7] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5, NSNumber *o6, NSNumber *o7, NSNumber *o8) {
                return @(o1.integerValue + o2.integerValue + o3.integerValue + o4.integerValue + o5.integerValue + o6.integerValue + o7.integerValue + o8.integerValue);
            }];
            break;
        }
        default:
            observable = [RxObservable zip:v resultSelector:^id(RxTuple *tuple) {
                return [[tuple.array objectEnumerator] reduce:@0 combine:RxCombinePlus()];
            }];
            break;
    }

    [observable subscribeNext:^(id o) {
        result = o;
    }];

    XCTAssertEqualObjects(result, @((n + 1) * n / 2));
}

- (void)_testZip_NeverN:(NSUInteger)n {
    NSAssert(n > 1, @"n < 2, n == %lu", n);

    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    NSMutableArray<RxTestableObservable *> *v = [NSMutableArray arrayWithCapacity:n];
    for (NSUInteger i = 0; i < n; i++) {
        [v addObject:[scheduler createHotObservable:@[
                next(150, @1),
        ]]];
    }

    RxObservable *observable;
    switch (n) {
        case 2: {
            observable = [RxObservable zip:v[0] and:v[1] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
                return @42;
            }];
            break;
        }
        case 3: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3) {
                return @42;
            }];
            break;
        }
        case 4: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4) {
                return @42;
            }];
            break;
        }
        case 5: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] and:v[4] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5) {
                return @42;
            }];
            break;
        }
        case 6: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] and:v[4] and:v[5] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5, NSNumber *o6) {
                return @42;
            }];
            break;
        }
        case 7: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] and:v[4] and:v[5] and:v[6] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5, NSNumber *o6, NSNumber *o7) {
                return @42;
            }];
            break;
        }
        case 8: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] and:v[4] and:v[5] and:v[6] and:v[7] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5, NSNumber *o6, NSNumber *o7, NSNumber *o8) {
                return @42;
            }];
            break;
        }
        default:
            observable = [RxObservable zip:v resultSelector:^id(RxTuple *tuple) {
                return @42;
            }];
            break;
    }

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return observable;
    }];

    XCTAssertEqualObjects(res.events, @[]);

    for (RxTestableObservable *v0 in v) {
        XCTAssertEqualObjects(v0.subscriptions, @[Subscription(200, 1000)]);
    }
}

- (void)_testZip_EmptyN:(NSUInteger)n {
    NSAssert(n > 1, @"n < 2, n == %lu", n);

    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    NSMutableArray<RxTestableObservable *> *v = [NSMutableArray arrayWithCapacity:n];
    for (NSUInteger i = 0; i < n; i++) {
        [v addObject:[scheduler createHotObservable:@[
                completed(200 + (i + 1) * 10)
        ]]];
    }

    RxObservable *observable;
    switch (n) {
        case 2: {
            observable = [RxObservable zip:v[0] and:v[1] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
                return @42;
            }];
            break;
        }
        case 3: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3) {
                return @42;
            }];
            break;
        }
        case 4: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4) {
                return @42;
            }];
            break;
        }
        case 5: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] and:v[4] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5) {
                return @42;
            }];
            break;
        }
        case 6: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] and:v[4] and:v[5] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5, NSNumber *o6) {
                return @42;
            }];
            break;
        }
        case 7: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] and:v[4] and:v[5] and:v[6] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5, NSNumber *o6, NSNumber *o7) {
                return @42;
            }];
            break;
        }
        case 8: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] and:v[4] and:v[5] and:v[6] and:v[7] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5, NSNumber *o6, NSNumber *o7, NSNumber *o8) {
                return @42;
            }];
            break;
        }
        default:
            observable = [RxObservable zip:v resultSelector:^id(RxTuple *tuple) {
                return @42;
            }];
            break;
    }

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return observable;
    }];

    XCTAssertEqualObjects(res.events, @[
            completed(200 + n * 10)
    ]);

    int i = 0;
    for (RxTestableObservable *v0 in v) {
        XCTAssertEqualObjects(v0.subscriptions, @[Subscription(200, 200 + (i + 1) * 10)]);
        i++;
    }
}

- (void)_testZip_SymmetricReturnN:(NSUInteger)n {
    NSAssert(n > 1, @"n < 2, n == %lu", n);

    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    NSMutableArray<RxTestableObservable *> *v = [NSMutableArray arrayWithCapacity:n];
    for (NSUInteger i = 0; i < n; i++) {
        RxTestableObservable *v0 = [scheduler createHotObservable:@[
                next(150, @1),
                next(200 + (i + 1) * 10, @(i + 1)),
                completed(400)
        ]];
        [v addObject:v0];
    }

    RxObservable *observable;
    switch (n) {
        case 2: {
            observable = [RxObservable zip:v[0] and:v[1] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
                return @(o1.integerValue + o2.integerValue);
            }];
            break;
        }
        case 3: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3) {
                return @(o1.integerValue + o2.integerValue + o3.integerValue);
            }];
            break;
        }
        case 4: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4) {
                return @(o1.integerValue + o2.integerValue + o3.integerValue + o4.integerValue);
            }];
            break;
        }
        case 5: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] and:v[4] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5) {
                return @(o1.integerValue + o2.integerValue + o3.integerValue + o4.integerValue + o5.integerValue);
            }];
            break;
        }
        case 6: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] and:v[4] and:v[5] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5, NSNumber *o6) {
                return @(o1.integerValue + o2.integerValue + o3.integerValue + o4.integerValue + o5.integerValue + o6.integerValue);
            }];
            break;
        }
        case 7: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] and:v[4] and:v[5] and:v[6] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5, NSNumber *o6, NSNumber *o7) {
                return @(o1.integerValue + o2.integerValue + o3.integerValue + o4.integerValue + o5.integerValue + o6.integerValue + o7.integerValue);
            }];
            break;
        }
        case 8: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] and:v[4] and:v[5] and:v[6] and:v[7] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5, NSNumber *o6, NSNumber *o7, NSNumber *o8) {
                return @(o1.integerValue + o2.integerValue + o3.integerValue + o4.integerValue + o5.integerValue + o6.integerValue + o7.integerValue + o8.integerValue);
            }];
            break;
        }
        default:
            observable = [RxObservable zip:v resultSelector:^id(RxTuple *tuple) {
                return [[tuple.array objectEnumerator] reduce:@0 combine:RxCombinePlus()];
            }];
            break;
    }

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return observable;
    }];


    NSArray *events = @[
            next(200 + n * 10, @(n * (n + 1) / 2)),
            completed(400)
    ];
    XCTAssertEqualObjects(res.events, events);
    for (RxTestableObservable *v0 in v) {
        XCTAssertEqualObjects(v0.subscriptions, @[Subscription(200, 400)]);
    }
}

- (void)_testZip_AllCompletedN:(NSUInteger)n {
    NSAssert(n > 1, @"n < 2, n == %lu", n);

    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    NSMutableArray<RxTestableObservable *> *v = [NSMutableArray arrayWithCapacity:n];
    for (NSUInteger i = 0; i < n; i++) {
        NSMutableArray *array = [@[
                next(150, @1),
        ] mutableCopy];
        for (NSUInteger k = 0; k <= i; k++) {
            [array addObject:next(200 + (k + 1) * 10, @(5 + k))];
        }
        [array addObject:completed(200 + (i + 2) * 10)];
        RxTestableObservable *v0 = [scheduler createHotObservable:array];
        [v addObject:v0];
    }

    RxObservable *observable;
    switch (n) {
        case 2: {
            observable = [RxObservable zip:v[0] and:v[1] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2) {
                return @(o1.integerValue + o2.integerValue);
            }];
            break;
        }
        case 3: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3) {
                return @(o1.integerValue + o2.integerValue + o3.integerValue);
            }];
            break;
        }
        case 4: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4) {
                return @(o1.integerValue + o2.integerValue + o3.integerValue + o4.integerValue);
            }];
            break;
        }
        case 5: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] and:v[4] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5) {
                return @(o1.integerValue + o2.integerValue + o3.integerValue + o4.integerValue + o5.integerValue);
            }];
            break;
        }
        case 6: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] and:v[4] and:v[5] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5, NSNumber *o6) {
                return @(o1.integerValue + o2.integerValue + o3.integerValue + o4.integerValue + o5.integerValue + o6.integerValue);
            }];
            break;
        }
        case 7: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] and:v[4] and:v[5] and:v[6] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5, NSNumber *o6, NSNumber *o7) {
                return @(o1.integerValue + o2.integerValue + o3.integerValue + o4.integerValue + o5.integerValue + o6.integerValue + o7.integerValue);
            }];
            break;
        }
        case 8: {
            observable = [RxObservable zip:v[0] and:v[1] and:v[2] and:v[3] and:v[4] and:v[5] and:v[6] and:v[7] resultSelector:^NSNumber *(NSNumber *o1, NSNumber *o2, NSNumber *o3, NSNumber *o4, NSNumber *o5, NSNumber *o6, NSNumber *o7, NSNumber *o8) {
                return @(o1.integerValue + o2.integerValue + o3.integerValue + o4.integerValue + o5.integerValue + o6.integerValue + o7.integerValue + o8.integerValue);
            }];
            break;
        }
        default:
            observable = [RxObservable zip:v resultSelector:^id(RxTuple *tuple) {
                return [[tuple.array objectEnumerator] reduce:@0 combine:RxCombinePlus()];
            }];
            break;
    }

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return observable;
    }];


    NSArray *events = @[
            next(210, @(5 * n)),
            completed(220 + (n - 2) * 10)
    ];
    XCTAssertEqualObjects(res.events, events);


    for (NSUInteger j = 0; j < n - 1; j++) {
        RxTestableObservable *v0 = v[j];
        XCTAssertEqualObjects(v0.subscriptions, @[Subscription(200, 220 + 10 * j)]);
    }
    XCTAssertEqualObjects(v.lastObject.subscriptions, @[Subscription(200, 220 + 10 * (n - 2))]);
}

#pragma mark - common

- (void)testZip_NeverEmpty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *n = [scheduler createHotObservable:@[
            next(150, @1)
    ]];
    
    RxTestableObservable *e = [scheduler createHotObservable:@[
            next(150, @1),
            completed(210)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable zip:n and:e resultSelector:RxCombinePlus()];
    }];

    NSArray *events = @[];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(n.subscriptions, @[
            Subscription(200, 1000)
    ]);

    XCTAssertEqualObjects(e.subscriptions, @[
            Subscription(200, 210)
    ]);
}

- (void)testZip_EmptyNever {
    // in rxswift not correct test method
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *n = [scheduler createHotObservable:@[
            next(150, @1),
            completed(210)
    ]];

    RxTestableObservable *e = [scheduler createHotObservable:@[
            next(150, @1),
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable zip:n and:e resultSelector:RxCombinePlus()];
    }];

    NSArray *events = @[];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(n.subscriptions, @[
            Subscription(200, 210)
    ]);

    XCTAssertEqualObjects(e.subscriptions, @[
            Subscription(200, 1000)
    ]);
}

- (void)testZip_EmptyNonEmpty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *n = [scheduler createHotObservable:@[
            next(150, @1),
            completed(210)
    ]];

    RxTestableObservable *e = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @2),
            completed(220)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable zip:n and:e resultSelector:RxCombinePlus()];
    }];

    NSArray *events = @[
            completed(215)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(n.subscriptions, @[
            Subscription(200, 210)
    ]);

    XCTAssertEqualObjects(e.subscriptions, @[
            Subscription(200, 215)
    ]);
}

- (void)testZip_NonEmptyEmpty {
    // in rxswift not correct test method
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *n = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @2),
            completed(220)
    ]];

    RxTestableObservable *e = [scheduler createHotObservable:@[
            next(150, @1),
            completed(210)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable zip:n and:e resultSelector:RxCombinePlus()];
    }];

    NSArray *events = @[
            completed(215)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(n.subscriptions, @[
            Subscription(200, 215)
    ]);

    XCTAssertEqualObjects(e.subscriptions, @[
            Subscription(200, 210)
    ]);
}

- (void)testZip_NeverNonEmpty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *n = [scheduler createHotObservable:@[
            next(150, @1),
    ]];

    RxTestableObservable *e = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @2),
            completed(220)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable zip:n and:e resultSelector:RxCombinePlus()];
    }];

    NSArray *events = @[

    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(n.subscriptions, @[
            Subscription(200, 1000)
    ]);

    XCTAssertEqualObjects(e.subscriptions, @[
            Subscription(200, 220)
    ]);
}

- (void)testZip_NonEmptyNever {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *n = [scheduler createHotObservable:@[
            next(150, @1),
    ]];

    RxTestableObservable *e = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @2),
            completed(220)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable zip:n and:e resultSelector:RxCombinePlus()];
    }];

    NSArray *events = @[

    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(n.subscriptions, @[
            Subscription(200, 1000)
    ]);

    XCTAssertEqualObjects(e.subscriptions, @[
            Subscription(200, 220)
    ]);
}

- (void)testZip_NonEmptyNonEmpty {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *o1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @2),
            completed(230)
    ]];

    RxTestableObservable *o2 = [scheduler createHotObservable:@[
            next(150, @1),
            next(220, @3),
            completed(240)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable zip:o1 and:o2 resultSelector:RxCombinePlus()];
    }];

    NSArray *events = @[
            next(220, @(2 + 3)),
            completed(240)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(o1.subscriptions, @[
            Subscription(200, 230)
    ]);

    XCTAssertEqualObjects(o2.subscriptions, @[
            Subscription(200, 240)
    ]);
}

- (void)testZip_EmptyError {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *o1 = [scheduler createHotObservable:@[
            next(150, @1),
            completed(230)
    ]];

    RxTestableObservable *o2 = [scheduler createHotObservable:@[
            next(150, @1),
            error(220, testError())
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable zip:o1 and:o2 resultSelector:RxCombinePlus()];
    }];

    NSArray *events = @[
            error(220, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(o1.subscriptions, @[
            Subscription(200, 220)
    ]);

    XCTAssertEqualObjects(o2.subscriptions, @[
            Subscription(200, 220)
    ]);
}

- (void)testZip_ErrorEmpty {
    // error in rx swift test
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *o1 = [scheduler createHotObservable:@[
            next(150, @1),
            error(220, testError())
    ]];

    RxTestableObservable *o2 = [scheduler createHotObservable:@[
            next(150, @1),
            completed(230)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable zip:o1 and:o2 resultSelector:RxCombinePlus()];
    }];

    NSArray *events = @[
            error(220, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(o1.subscriptions, @[
            Subscription(200, 220)
    ]);

    XCTAssertEqualObjects(o2.subscriptions, @[
            Subscription(200, 220)
    ]);
}

- (void)testZip_NeverError {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *o1 = [scheduler createHotObservable:@[
            next(150, @1),
    ]];

    RxTestableObservable *o2 = [scheduler createHotObservable:@[
            next(150, @1),
            error(220, testError())
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable zip:o1 and:o2 resultSelector:RxCombinePlus()];
    }];

    NSArray *events = @[
            error(220, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(o1.subscriptions, @[
            Subscription(200, 220)
    ]);

    XCTAssertEqualObjects(o2.subscriptions, @[
            Subscription(200, 220)
    ]);
}

- (void)testZip_ErrorNever {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *o1 = [scheduler createHotObservable:@[
            next(150, @1),
            error(220, testError())
    ]];

    RxTestableObservable *o2 = [scheduler createHotObservable:@[
            next(150, @1),
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable zip:o1 and:o2 resultSelector:RxCombinePlus()];
    }];

    NSArray *events = @[
            error(220, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(o1.subscriptions, @[
            Subscription(200, 220)
    ]);

    XCTAssertEqualObjects(o2.subscriptions, @[
            Subscription(200, 220)
    ]);
}

- (void)testZip_ErrorError {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *o1 = [scheduler createHotObservable:@[
            next(150, @1),
            error(230, testError1())
    ]];

    RxTestableObservable *o2 = [scheduler createHotObservable:@[
            next(150, @1),
            error(220, testError2())
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable zip:o1 and:o2 resultSelector:RxCombinePlus()];
    }];

    NSArray *events = @[
            error(220, testError2())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(o1.subscriptions, @[
            Subscription(200, 220)
    ]);

    XCTAssertEqualObjects(o2.subscriptions, @[
            Subscription(200, 220)
    ]);
}

- (void)testZip_SomeError {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *o1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @2),
            completed(230)
    ]];

    RxTestableObservable *o2 = [scheduler createHotObservable:@[
            next(150, @1),
            error(220, testError1())
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable zip:o1 and:o2 resultSelector:RxCombinePlus()];
    }];

    NSArray *events = @[
            error(220, testError1())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(o1.subscriptions, @[
            Subscription(200, 220)
    ]);

    XCTAssertEqualObjects(o2.subscriptions, @[
            Subscription(200, 220)
    ]);
}

- (void)testZip_ErrorSome {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *o1 = [scheduler createHotObservable:@[
            next(150, @1),
            error(220, testError1())
    ]];

    RxTestableObservable *o2 = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @2),
            completed(230)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable zip:o1 and:o2 resultSelector:RxCombinePlus()];
    }];

    NSArray *events = @[
            error(220, testError1())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(o1.subscriptions, @[
            Subscription(200, 220)
    ]);

    XCTAssertEqualObjects(o2.subscriptions, @[
            Subscription(200, 220)
    ]);
}

- (void)testZip_LeftCompletesFirst {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *o1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            completed(220)
    ]];

    RxTestableObservable *o2 = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @4),
            completed(225)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable zip:o1 and:o2 resultSelector:RxCombinePlus()];
    }];

    NSArray *events = @[
            next(215, @(2 + 4)),
            completed(225)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(o1.subscriptions, @[
            Subscription(200, 220)
    ]);

    XCTAssertEqualObjects(o2.subscriptions, @[
            Subscription(200, 225)
    ]);
}

- (void)testZip_RightCompletesFirst {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *o1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @2),
            completed(220)
    ]];

    RxTestableObservable *o2 = [scheduler createHotObservable:@[
            next(150, @1),
            next(215, @4),
            completed(225)
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable zip:o2 and:o1 resultSelector:RxCombinePlus()];
    }];

    NSArray *events = @[
            next(215, @(2 + 4)),
            completed(225)
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(o1.subscriptions, @[
            Subscription(200, 220)
    ]);

    XCTAssertEqualObjects(o2.subscriptions, @[
            Subscription(200, 225)
    ]);
}

- (void)testZip_LeftTriggersSelectorError {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *o1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(220, @2),
            completed(220)
    ]];

    RxTestableObservable *o2 = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @4),
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable zip:o1 and:o2 resultSelector:^id(id _o1, id _o2) {
            @throw testError();
        }];
    }];

    NSArray *events = @[
            error(220, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(o1.subscriptions, @[
            Subscription(200, 220)
    ]);

    XCTAssertEqualObjects(o2.subscriptions, @[
            Subscription(200, 220)
    ]);
}

- (void)testZip_RightTriggersSelectorError {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *o1 = [scheduler createHotObservable:@[
            next(150, @1),
            next(220, @2),
            completed(220)
    ]];

    RxTestableObservable *o2 = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @4),
    ]];

    RxTestableObserver *res = [scheduler start:^RxObservable * {
        return [RxObservable zip:o2 and:o1 resultSelector:^id(id _o1, id _o2) {
            @throw testError();
        }];
    }];

    NSArray *events = @[
            error(220, testError())
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(o1.subscriptions, @[
            Subscription(200, 220)
    ]);

    XCTAssertEqualObjects(o2.subscriptions, @[
            Subscription(200, 220)
    ]);
}

@end

@implementation RxObservableMultipleTestZip (With2)

- (void)testZip_ImmediateSchedule2 {
    [self _testZip_ImmediateScheduleN:2];
}

- (void)testZip_Never2 {
    [self _testZip_NeverN:2];
}

- (void)testZip_Empty2 {
    [self _testZip_EmptyN:2];
}

- (void)testZip_SymmetricReturn2 {
    [self _testZip_SymmetricReturnN:2];
}

- (void)testZip_AllCompleted2 {
    [self _testZip_AllCompletedN:2];
}

@end

@implementation RxObservableMultipleTestZip (With3)

- (void)testZip_ImmediateSchedule3 {
    [self _testZip_ImmediateScheduleN:3];
}

- (void)testZip_Never3 {
    [self _testZip_NeverN:3];
}

- (void)testZip_Empty3 {
    [self _testZip_EmptyN:3];
}

- (void)testZip_SymmetricReturn3 {
    [self _testZip_SymmetricReturnN:3];
}

- (void)testZip_AllCompleted3 {
    [self _testZip_AllCompletedN:3];
}

@end

@implementation RxObservableMultipleTestZip (With4)

- (void)testZip_ImmediateSchedule4 {
    [self _testZip_ImmediateScheduleN:4];
}

- (void)testZip_Never4 {
    [self _testZip_NeverN:4];
}

- (void)testZip_Empty4 {
    [self _testZip_EmptyN:4];
}

- (void)testZip_SymmetricReturn4 {
    [self _testZip_SymmetricReturnN:4];
}

- (void)testZip_AllCompleted4 {
    [self _testZip_AllCompletedN:4];
}

@end

@implementation RxObservableMultipleTestZip (With5)

- (void)testZip_ImmediateSchedule5 {
    [self _testZip_ImmediateScheduleN:5];
}

- (void)testZip_Never5 {
    [self _testZip_NeverN:5];
}

- (void)testZip_Empty5 {
    [self _testZip_EmptyN:5];
}

- (void)testZip_SymmetricReturn5 {
    [self _testZip_SymmetricReturnN:5];
}

- (void)testZip_AllCompleted5 {
    [self _testZip_AllCompletedN:5];
}

@end

@implementation RxObservableMultipleTestZip (With6)

- (void)testZip_ImmediateSchedule6 {
    [self _testZip_ImmediateScheduleN:6];
}

- (void)testZip_Never6 {
    [self _testZip_NeverN:6];
}

- (void)testZip_Empty6 {
    [self _testZip_EmptyN:6];
}

- (void)testZip_SymmetricReturn6 {
    [self _testZip_SymmetricReturnN:6];
}

- (void)testZip_AllCompleted6 {
    [self _testZip_AllCompletedN:6];
}

@end

@implementation RxObservableMultipleTestZip (With7)

- (void)testZip_ImmediateSchedule7 {
    [self _testZip_ImmediateScheduleN:7];
}

- (void)testZip_Never7 {
    [self _testZip_NeverN:7];
}

- (void)testZip_Empty7 {
    [self _testZip_EmptyN:7];
}

- (void)testZip_SymmetricReturn7 {
    [self _testZip_SymmetricReturnN:7];
}

- (void)testZip_AllCompleted7 {
    [self _testZip_AllCompletedN:7];
}

@end

@implementation RxObservableMultipleTestZip (With8)

- (void)testZip_ImmediateSchedule8 {
    [self _testZip_ImmediateScheduleN:8];
}

- (void)testZip_Never8 {
    [self _testZip_NeverN:8];
}

- (void)testZip_Empty8 {
    [self _testZip_EmptyN:8];
}

- (void)testZip_SymmetricReturn8 {
    [self _testZip_SymmetricReturnN:8];
}

- (void)testZip_AllCompleted8 {
    [self _testZip_AllCompletedN:8];
}

@end

@implementation RxObservableMultipleTestZip (With10)

- (void)testZip_ImmediateSchedule10 {
    [self _testZip_ImmediateScheduleN:10];
}

- (void)testZip_Never10 {
    [self _testZip_NeverN:10];
}

- (void)testZip_Empty10 {
    [self _testZip_EmptyN:10];
}

- (void)testZip_SymmetricReturn10 {
    [self _testZip_SymmetricReturnN:10];
}

- (void)testZip_AllCompleted10 {
    [self _testZip_AllCompletedN:10];
}

@end
