//
//  RxRunLoopLock
//  RxObjC
// 
//  Created by Pavel Malkov on 13.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxRunLoopLock.h"
#import <RxObjC/RxObjC.h>

@implementation RxRunLoopLock {
    CFRunLoopRef _currentRunLoop;
    int32_t _calledRun;
    int32_t _calledStop;
}

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _currentRunLoop = CFRunLoopGetCurrent();
    }
    return self;
}

- (void)dispatch:(nonnull void (^)())action {
    CFRunLoopPerformBlock(_currentRunLoop, kCFRunLoopDefaultMode, ^{
        if ([RxCurrentThreadScheduler sharedInstance].isScheduleRequired) {
            [[RxCurrentThreadScheduler sharedInstance] schedule:nil action:^id <RxDisposable>(RxStateType __unused _) {
                action();
                return [RxNopDisposable sharedInstance];
            }];
        } else {
            action();
        }
    });
    CFRunLoopWakeUp(_currentRunLoop);
}

- (void)stop {
    if (OSAtomicIncrement32(&_calledStop) != 1) {
        return;
    }
    @weakify(self);
    CFRunLoopPerformBlock(_currentRunLoop, kCFRunLoopDefaultMode, ^{
        @strongify(self);
        if (!self) {
            return;
        }
        CFRunLoopStop(self->_currentRunLoop);
    });
    CFRunLoopWakeUp(_currentRunLoop);
}

- (void)run {
    if (OSAtomicIncrement32(&_calledRun) != 1) {
        rx_fatalError(@"Run can be only called once");
    }
    CFRunLoopRun();
}


@end