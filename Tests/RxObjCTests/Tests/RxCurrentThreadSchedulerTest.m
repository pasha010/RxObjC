//
//  RxCurrentThreadSchedulerTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 10.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"
#import "RxCurrentThreadScheduler.h"
#import "RxNopDisposable.h"

@interface RxCurrentThreadSchedulerTest : RxTest

@end

@implementation RxCurrentThreadSchedulerTest

- (void)testCurrentThreadScheduler_scheduleRequired {
    XCTAssertTrue([RxCurrentThreadScheduler sharedInstance].isScheduleRequired);
    
    __block BOOL executed = NO;
    [[RxCurrentThreadScheduler sharedInstance] schedule:nil action:^id<RxDisposable> _Nonnull(RxStateType _Nonnull s) {
        executed = YES;
        XCTAssertTrue(![RxCurrentThreadScheduler sharedInstance].isScheduleRequired);
        return [RxNopDisposable sharedInstance];
    }];
    XCTAssertTrue(executed);
}

- (void)testCurrentThreadScheduler_basicScenario {
    XCTAssertTrue([RxCurrentThreadScheduler sharedInstance].isScheduleRequired);
    
    __block NSMutableArray<NSNumber *> *messages = [NSMutableArray array];
    
    [[RxCurrentThreadScheduler sharedInstance] schedule:nil action:^id<RxDisposable> _Nonnull(RxStateType _Nonnull s) {
        [messages addObject:@1];
        [[RxCurrentThreadScheduler sharedInstance] schedule:nil action:^id<RxDisposable> _Nonnull(RxStateType _Nonnull _s) {
            [messages addObject:@3];
            [[RxCurrentThreadScheduler sharedInstance] schedule:nil action:^id<RxDisposable> _Nonnull(RxStateType _Nonnull __s) {
                [messages addObject:@5];
                return [RxNopDisposable sharedInstance];
            }];
            [messages addObject:@4];
            return [RxNopDisposable sharedInstance];
        }];
        [messages addObject:@2];
        return [RxNopDisposable sharedInstance];
    }];
    
    NSArray *array = @[@1, @2, @3, @4, @5];
    XCTAssertTrue([messages isEqualToArray:array]);
}

- (void)testCurrentThreadScheduler_disposing1 {
    XCTAssertTrue([RxCurrentThreadScheduler sharedInstance].isScheduleRequired);
    
    __block NSMutableArray<NSNumber *> *messages = [NSMutableArray array];
    
    [[RxCurrentThreadScheduler sharedInstance] schedule:nil action:^id<RxDisposable> _Nonnull(RxStateType _Nonnull s) {
        [messages addObject:@1];
        id <RxDisposable> disposable3 = [[RxCurrentThreadScheduler sharedInstance] schedule:nil action:^id<RxDisposable> _Nonnull(RxStateType _Nonnull _s) {
            [messages addObject:@3];
            id <RxDisposable> disposable5 = [[RxCurrentThreadScheduler sharedInstance] schedule:nil action:^id<RxDisposable> _Nonnull(RxStateType _Nonnull __s) {
                [messages addObject:@5];
                return [RxNopDisposable sharedInstance];
            }];
            [disposable5 dispose];
            [messages addObject:@4];
            return disposable5;
        }];
        [messages addObject:@2];
        return disposable3;
    }];
    
    NSArray *array = @[@1, @2, @3, @4];
    XCTAssertTrue([messages isEqualToArray:array]);
}

- (void)testCurrentThreadScheduler_disposing2 {
    XCTAssertTrue([RxCurrentThreadScheduler sharedInstance].isScheduleRequired);

    __block NSMutableArray<NSNumber *> *messages = [NSMutableArray array];
    [[RxCurrentThreadScheduler sharedInstance] schedule:nil action:^id<RxDisposable> _Nonnull(RxStateType _Nonnull s) {
        [messages addObject:@1];
        id <RxDisposable> disposable3 = [[RxCurrentThreadScheduler sharedInstance] schedule:nil action:^id<RxDisposable> _Nonnull(RxStateType _Nonnull __s) {
            [messages addObject:@3];
            id <RxDisposable> disposable5 = [[RxCurrentThreadScheduler sharedInstance] schedule:nil action:^id<RxDisposable> _Nonnull(RxStateType _Nonnull __s) {
                [messages addObject:@5];
                return [RxNopDisposable sharedInstance];
            }];
            [messages addObject:@4];
            return disposable5;
        }];
        [disposable3 dispose];
        [messages addObject:@2];
        return disposable3;
    }];
    NSArray *array = @[@1, @2];
    XCTAssertTrue([messages isEqualToArray:array]);
}

@end
