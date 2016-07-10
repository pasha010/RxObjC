//
//  RxVirtualSchedulerTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 10.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RxTest.h"
#import "RxTestVirtualScheduler.h"
#import "RxNopDisposable.h"

@interface RxVirtualSchedulerTest : RxTest

@end

@implementation RxVirtualSchedulerTest

- (void)testVirtualScheduler_initialClock {
    RxTestVirtualScheduler *scheduler = [[RxTestVirtualScheduler alloc] initWithInitialClock:10];
    XCTAssertTrue([[scheduler now] isEqualToDate:[NSDate dateWithTimeIntervalSince1970:100.0]]);
    XCTAssertTrue([[scheduler clock] isEqual:@10]);
}

- (void)testVirtualScheduler_start {
    RxTestVirtualScheduler *scheduler = [[RxTestVirtualScheduler alloc] init];

    NSMutableArray<NSNumber *> *times = [NSMutableArray array];

    [scheduler scheduleRelative:nil dueTime:10.0 action:^id <RxDisposable>(id o) {
        [times addObject:[scheduler clock]];
        [scheduler scheduleRelative:nil dueTime:20.0 action:^id <RxDisposable>(id _o) {
            [times addObject:[scheduler clock]];
            return [RxNopDisposable sharedInstance];
        }];
        return [scheduler schedule:nil action:^id <RxDisposable>(RxStateType _o) {
            [times addObject:[scheduler clock]];
            return [RxNopDisposable sharedInstance];
        }];
    }];

    [scheduler start];

    NSArray *array = @[@1, @1, @3];
    XCTAssertTrue([times isEqualToArray:array]);
}

- (void)testVirtualScheduler_disposeStart {
    RxTestVirtualScheduler *scheduler = [[RxTestVirtualScheduler alloc] init];

    NSMutableArray<NSNumber *> *times = [NSMutableArray array];

    [scheduler scheduleRelative:nil dueTime:10.0 action:^id <RxDisposable>(id o) {
        [times addObject:[scheduler clock]];
        id <RxDisposable> d = [scheduler scheduleRelative:nil dueTime:20.0 action:^id <RxDisposable>(id _o) {
            [times addObject:[scheduler clock]];
            return [RxNopDisposable sharedInstance];
        }];
        id <RxDisposable> d2 = [scheduler schedule:nil action:^id <RxDisposable>(RxStateType _o) {
            [times addObject:[scheduler clock]];
            return [RxNopDisposable sharedInstance];
        }];

        [d2 dispose];
        [d dispose];
        return [RxNopDisposable sharedInstance];
    }];

    [scheduler start];

    NSArray *array = @[@1];
    XCTAssertTrue([times isEqualToArray:array]);
}

- (void)testVirtualScheduler_advanceToAfter {
    RxTestVirtualScheduler *scheduler = [[RxTestVirtualScheduler alloc] init];

    NSMutableArray<NSNumber *> *times = [NSMutableArray array];

    [scheduler scheduleRelative:nil dueTime:10.0 action:^id <RxDisposable>(id o) {
        [times addObject:[scheduler clock]];
        [scheduler scheduleRelative:nil dueTime:20.0 action:^id <RxDisposable>(id _o) {
            [times addObject:[scheduler clock]];
            return [RxNopDisposable sharedInstance];
        }];
        return [scheduler schedule:nil action:^id <RxDisposable>(RxStateType _o) {
            [times addObject:[scheduler clock]];
            return [RxNopDisposable sharedInstance];
        }];
    }];

    [scheduler advanceTo:@10];

    NSArray *array = @[@1, @1, @3];
    XCTAssertTrue([times isEqualToArray:array]);
}

- (void)testVirtualScheduler_advanceToBefore {
    RxTestVirtualScheduler *scheduler = [[RxTestVirtualScheduler alloc] init];

    NSMutableArray<NSNumber *> *times = [NSMutableArray array];

    @weakify(scheduler);
    [scheduler scheduleRelative:nil dueTime:10.0 action:^id <RxDisposable>(id o) {
        @strongify(scheduler);
        [times addObject:[scheduler clock]];
        [scheduler scheduleRelative:nil dueTime:20.0 action:^id <RxDisposable>(id _o) {
            [times addObject:[scheduler clock]];
            return [RxNopDisposable sharedInstance];
        }];
        return [scheduler schedule:nil action:^id <RxDisposable>(RxStateType _o) {
            [times addObject:[scheduler clock]];
            return [RxNopDisposable sharedInstance];
        }];
    }];

    [scheduler advanceTo:@1];

    NSArray *array = @[@1, @1];
    XCTAssertTrue([times isEqualToArray:array]);
}

- (void)testVirtualScheduler_disposeAdvanceTo {
    RxTestVirtualScheduler *scheduler = [[RxTestVirtualScheduler alloc] init];

    NSMutableArray<NSNumber *> *times = [NSMutableArray array];

    @weakify(scheduler);
    [scheduler scheduleRelative:nil dueTime:10.0 action:^id <RxDisposable>(id o) {
        @strongify(scheduler);
        [times addObject:[scheduler clock]];
        id <RxDisposable> d1 = [scheduler scheduleRelative:nil dueTime:20.0 action:^id <RxDisposable>(id _o) {
            [times addObject:[scheduler clock]];
            return [RxNopDisposable sharedInstance];
        }];
        id <RxDisposable> d2 = [scheduler schedule:nil action:^id <RxDisposable>(RxStateType _o) {
            [times addObject:[scheduler clock]];
            return [RxNopDisposable sharedInstance];
        }];

        [d1 dispose];
        [d2 dispose];
        return [RxNopDisposable sharedInstance];
    }];

    [scheduler advanceTo:@20];

    NSArray *array = @[@1];
    XCTAssertTrue([times isEqualToArray:array]);
}

- (void)testVirtualScheduler_stop {
    RxTestVirtualScheduler *scheduler = [[RxTestVirtualScheduler alloc] init];

    NSMutableArray<NSNumber *> *times = [NSMutableArray array];

    @weakify(scheduler);
    [scheduler scheduleRelative:nil dueTime:10.0 action:^id <RxDisposable>(id o) {
        @strongify(scheduler);
        [times addObject:[scheduler clock]];
        [scheduler scheduleRelative:nil dueTime:20.0 action:^id <RxDisposable>(id _o) {
            [times addObject:[scheduler clock]];
            return [RxNopDisposable sharedInstance];
        }];
        [scheduler schedule:nil action:^id <RxDisposable>(RxStateType _o) {
            [times addObject:[scheduler clock]];
            return [RxNopDisposable sharedInstance];
        }];
        [scheduler stop];
        return [RxNopDisposable sharedInstance];
    }];

    [scheduler start];

    NSArray *array = @[@1];
    XCTAssertTrue([times isEqualToArray:array]);
}

- (void)testVirtualScheduler_sleep {
    RxTestVirtualScheduler *scheduler = [[RxTestVirtualScheduler alloc] init];

    NSMutableArray<NSNumber *> *times = [NSMutableArray array];

    @weakify(scheduler);
    [scheduler scheduleRelative:nil dueTime:10.0 action:^id <RxDisposable>(id o) {
        @strongify(scheduler);
        [times addObject:[scheduler clock]];
        [scheduler sleep:10];
        [scheduler scheduleRelative:nil dueTime:20.0 action:^id <RxDisposable>(id _o) {
            [times addObject:[scheduler clock]];
            return [RxNopDisposable sharedInstance];
        }];
        [scheduler schedule:nil action:^id <RxDisposable>(RxStateType _o) {
            [times addObject:[scheduler clock]];
            return [RxNopDisposable sharedInstance];
        }];
        return [RxNopDisposable sharedInstance];
    }];

    [scheduler start];

    NSArray *array = @[@1, @11, @13];
    XCTAssertTrue([times isEqualToArray:array]);
}

- (void)testVirtualScheduler_stress {
    RxTestVirtualScheduler *scheduler = [[RxTestVirtualScheduler alloc] init];

    NSMutableArray<NSNumber *> *times = [NSMutableArray array];
    NSMutableArray<NSNumber *> *ticks = [NSMutableArray array];

    @weakify(scheduler);
    for (NSUInteger i = 0; i < 20000; i++) {
        int random = rand() % 10000;

        [times addObject:@(random)];

        [scheduler scheduleRelative:nil dueTime:10 * random action:^id <RxDisposable>(id o) {
            @strongify(scheduler);
            [ticks addObject:[scheduler clock]];
            return [RxNopDisposable sharedInstance];
        }];
    }

    [scheduler start];

    [times sortUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES] ]];

    XCTAssertTrue([times isEqualToArray:ticks]);
}

@end
