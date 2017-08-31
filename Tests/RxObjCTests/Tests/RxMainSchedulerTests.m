//
//  RxMainSchedulerTests.m
//  RxObjC
//
//  Created by Pavel Malkov on 10.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"
#import "RxMainScheduler.h"
#import "RxNopDisposable.h"

@interface RxMainSchedulerTests : RxTest

@end

@implementation RxMainSchedulerTests

void runRunLoop() {
    for (NSUInteger i = 0; i < 10; i++) {
        CFRunLoopRef currentRunLoop = CFRunLoopGetCurrent();
        dispatch_async(dispatch_get_main_queue(), ^{
            CFRunLoopStop(currentRunLoop);
        });
        CFRunLoopWakeUp(currentRunLoop);
        CFRunLoopRun();
    }
}

- (void)testMainScheduler_basicScenario {
    NSMutableArray<NSNumber *> *messages = [NSMutableArray array];
    __block BOOL executedImmediatelly = NO;

    [[RxMainScheduler instance] schedule:nil action:^id <RxDisposable>(RxStateType s) {
        executedImmediatelly = YES;
        [messages addObject:@1];
        [[RxMainScheduler instance] schedule:nil action:^id <RxDisposable>(RxStateType o) {
            [messages addObject:@3];
            [[RxMainScheduler instance] schedule:nil action:^id <RxDisposable>(RxStateType _o) {
                [messages addObject:@5];
                return [RxNopDisposable sharedInstance];
            }];
            [messages addObject:@4];
            return [RxNopDisposable sharedInstance];
        }];
        [messages addObject:@2];
        return [RxNopDisposable sharedInstance];
    }];

    XCTAssertTrue(executedImmediatelly);

    runRunLoop();

    NSArray *array = @[@1, @2, @3, @4, @5];
    XCTAssertTrue([messages isEqualToArray:array]);
}

- (void)testMainScheduler_disposing1 {
    NSMutableArray<NSNumber *> *messages = [NSMutableArray array];

    [[RxMainScheduler instance] schedule:nil action:^id <RxDisposable>(RxStateType s) {
        [messages addObject:@1];
        id <RxDisposable> d3 = [[RxMainScheduler instance] schedule:nil action:^id <RxDisposable>(RxStateType o) {
            [messages addObject:@3];
            id <RxDisposable> d5 = [[RxMainScheduler instance] schedule:nil action:^id <RxDisposable>(RxStateType _o) {
                [messages addObject:@5];
                return [RxNopDisposable sharedInstance];
            }];
            [d5 dispose];
            [messages addObject:@4];
            return d5;
        }];
        [messages addObject:@2];
        return d3;
    }];

    runRunLoop();

    NSArray *array = @[@1, @2, @3, @4];
    XCTAssertTrue([messages isEqualToArray:array]);
}

- (void)testMainScheduler_disposing2 {
    NSMutableArray<NSNumber *> *messages = [NSMutableArray array];

    [[RxMainScheduler instance] schedule:nil action:^id <RxDisposable>(RxStateType o) {
        [messages addObject:@1];
        id <RxDisposable> d3 = [[RxMainScheduler instance] schedule:nil action:^id <RxDisposable>(RxStateType o) {
            [messages addObject:@3];
            id <RxDisposable> d5 = [[RxMainScheduler instance] schedule:nil action:^id <RxDisposable>(RxStateType o) {
                [messages addObject:@5];
                return [RxNopDisposable sharedInstance];
            }];
            [messages addObject:@4];
            return d5;
        }];
        [d3 dispose];
        [messages addObject:@2];
        return d3;
    }];

    runRunLoop();

    NSArray *array = @[@1, @2];
    XCTAssertTrue([messages isEqualToArray:array]);
}
@end
