//
//  RxHistoricalSchedulerTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 10.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RxTest.h"
#import "RxHistoricalScheduler.h"
#import "RxNopDisposable.h"

@interface RxHistoricalSchedulerTest : RxTest

@end

@implementation RxHistoricalSchedulerTest

- (void)testHistoricalScheduler_initialClock {
    RxHistoricalScheduler *scheduler = [[RxHistoricalScheduler alloc] initWithInitialClock:[NSDate dateWithTimeIntervalSince1970:10.0]];
    XCTAssertTrue([[scheduler now] isEqualToDate:[NSDate dateWithTimeIntervalSince1970:10.0]]);
    XCTAssertTrue([[scheduler clock] isEqualToDate:[NSDate dateWithTimeIntervalSince1970:10.0]]);
}

- (void)testHistoricalScheduler_start {
    RxHistoricalScheduler *scheduler = [[RxHistoricalScheduler alloc] init];
    
    NSMutableArray<NSDate *> *times = [NSMutableArray array];

    [scheduler scheduleRelative:nil dueTime:10.0 action:^id <RxDisposable>(id _) {
        [times addObject:[scheduler now]];
        [scheduler scheduleRelative:nil dueTime:20.0 action:^id <RxDisposable>(id o) {
            [times addObject:[scheduler now]];
            return [RxNopDisposable sharedInstance];
        }];
        return [scheduler schedule:nil action:^id <RxDisposable>(RxStateType o) {
            [times addObject:[scheduler now]];
            return [RxNopDisposable sharedInstance];
        }];
    }];

    [scheduler start];

    NSArray *array = @[
            [NSDate dateWithTimeIntervalSince1970:10.0],
            [NSDate dateWithTimeIntervalSince1970:10.0],
            [NSDate dateWithTimeIntervalSince1970:30.0],
    ];
    XCTAssertTrue([times isEqualToArray:array]);
}

- (void)testHistoricalScheduler_disposeStart {
    RxHistoricalScheduler *scheduler = [[RxHistoricalScheduler alloc] init];

    NSMutableArray<NSDate *> *times = [NSMutableArray array];

    [scheduler scheduleRelative:nil dueTime:10.0 action:^id <RxDisposable>(id o) {
        [times addObject:[scheduler now]];

        id <RxDisposable> d = [scheduler scheduleRelative:nil dueTime:20.0 action:^id <RxDisposable>(id _) {
            [times addObject:[scheduler now]];
            return [RxNopDisposable sharedInstance];
        }];

        id <RxDisposable> d2 = [scheduler schedule:nil action:^id <RxDisposable>(RxStateType _o) {
            [times addObject:[scheduler now]];
            return [RxNopDisposable sharedInstance];
        }];

        [d2 dispose];
        [d dispose];
        return [RxNopDisposable sharedInstance];
    }];

    [scheduler start];

    NSArray *array = @[
            [NSDate dateWithTimeIntervalSince1970:10.0]
    ];
    XCTAssertTrue([times isEqualToArray:array]);
}

- (void)testHistoricalScheduler_advanceToAfter {
    RxHistoricalScheduler *scheduler = [[RxHistoricalScheduler alloc] init];

    NSMutableArray<NSDate *> *times = [NSMutableArray array];

    [scheduler scheduleRelative:nil dueTime:10.0 action:^id <RxDisposable>(id o) {
        [times addObject:[scheduler now]];

        [scheduler scheduleRelative:nil dueTime:20.0 action:^id <RxDisposable>(id _o) {
            [times addObject:[scheduler now]];
            return [RxNopDisposable sharedInstance];
        }];
        return [scheduler schedule:nil action:^id <RxDisposable>(RxStateType _o) {
            [times addObject:[scheduler now]];
            return [RxNopDisposable sharedInstance];
        }];
    }];

    [scheduler advanceTo:[NSDate dateWithTimeIntervalSince1970:100.0]];

    NSArray *array = @[
            [NSDate dateWithTimeIntervalSince1970:10.0],
            [NSDate dateWithTimeIntervalSince1970:10.0],
            [NSDate dateWithTimeIntervalSince1970:30.0],
    ];
    XCTAssertTrue([times isEqualToArray:array]);
}

- (void)testHistoricalScheduler_advanceToBefore {
    RxHistoricalScheduler *scheduler = [[RxHistoricalScheduler alloc] init];

    NSMutableArray<NSDate *> *times = [NSMutableArray array];

    @weakify(scheduler);
    [scheduler scheduleRelative:nil dueTime:10.0 action:^id <RxDisposable>(id o) {
        @strongify(scheduler);
        [times addObject:[scheduler now]];

        [scheduler scheduleRelative:nil dueTime:10.0 action:^id <RxDisposable>(id _o) {
            [times addObject:[scheduler now]];
            return [RxNopDisposable sharedInstance];
        }];
        
        return [scheduler schedule:nil action:^id <RxDisposable>(RxStateType _o) {
            [times addObject:[scheduler now]];
            return [RxNopDisposable sharedInstance];
        }];
    }];

    [scheduler advanceTo:[NSDate dateWithTimeIntervalSince1970:10.0]];

    NSArray *array = @[
            [NSDate dateWithTimeIntervalSince1970:10.0],
            [NSDate dateWithTimeIntervalSince1970:10.0],
    ];
    XCTAssertTrue([times isEqualToArray:array]);
}

- (void)testHistoricalScheduler_disposeAdvanceTo {
    RxHistoricalScheduler *scheduler = [[RxHistoricalScheduler alloc] init];

    NSMutableArray<NSDate *> *times = [NSMutableArray array];

    @weakify(scheduler);
    [scheduler scheduleRelative:nil dueTime:10.0 action:^id <RxDisposable>(id o) {
        @strongify(scheduler);
        [times addObject:[scheduler now]];

        id <RxDisposable> d1 = [scheduler scheduleRelative:nil dueTime:10.0 action:^id <RxDisposable>(id _o) {
            [times addObject:[scheduler now]];
            return [RxNopDisposable sharedInstance];
        }];

        id <RxDisposable> d2 = [scheduler schedule:nil action:^id <RxDisposable>(RxStateType _o) {
            [times addObject:[scheduler now]];
            return [RxNopDisposable sharedInstance];
        }];
        [d1 dispose];
        [d2 dispose];

        return [RxNopDisposable sharedInstance];
    }];

    [scheduler advanceTo:[NSDate dateWithTimeIntervalSince1970:200.0]];

    NSArray *array = @[
            [NSDate dateWithTimeIntervalSince1970:10.0],
    ];
    XCTAssertTrue([times isEqualToArray:array]);
}

- (void)testHistoricalScheduler_stop {
    RxHistoricalScheduler *scheduler = [[RxHistoricalScheduler alloc] init];

    NSMutableArray<NSDate *> *times = [NSMutableArray array];

    @weakify(scheduler);
    [scheduler scheduleRelative:nil dueTime:10.0 action:^id <RxDisposable>(id o) {
        @strongify(scheduler);

        [times addObject:[scheduler now]];
        [scheduler scheduleRelative:nil dueTime:20.0 action:^id <RxDisposable>(id _o) {
            [times addObject:[scheduler now]];
            return [RxNopDisposable sharedInstance];
        }];
        [scheduler schedule:nil action:^id <RxDisposable>(RxStateType _o) {
            [times addObject:[scheduler now]];
            return [RxNopDisposable sharedInstance];
        }];

        [scheduler stop];
        return [RxNopDisposable sharedInstance];
    }];

    [scheduler start];

    NSArray *array = @[
            [NSDate dateWithTimeIntervalSince1970:10.0],
    ];
    XCTAssertTrue([times isEqualToArray:array]);
}

- (void)testHistoricalScheduler_sleep {
    RxHistoricalScheduler *scheduler = [[RxHistoricalScheduler alloc] init];

    NSMutableArray<NSDate *> *times = [NSMutableArray array];

    @weakify(scheduler);
    [scheduler scheduleRelative:nil dueTime:10.0 action:^id <RxDisposable>(id o) {
        @strongify(scheduler);

        [times addObject:[scheduler now]];

        [scheduler sleep:100];

        [scheduler scheduleRelative:nil dueTime:20.0 action:^id <RxDisposable>(id _o) {
            [times addObject:[scheduler now]];
            return [RxNopDisposable sharedInstance];
        }];

        [scheduler schedule:nil action:^id <RxDisposable>(RxStateType _o) {
            [times addObject:[scheduler now]];
            return [RxNopDisposable sharedInstance];
        }];

        return [RxNopDisposable sharedInstance];
    }];

    [scheduler start];

    NSArray *array = @[
            [NSDate dateWithTimeIntervalSince1970:10.0],
            [NSDate dateWithTimeIntervalSince1970:110.0],
            [NSDate dateWithTimeIntervalSince1970:130.0],
    ];
    XCTAssertTrue([times isEqualToArray:array]);
}

@end
