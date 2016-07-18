//
//  RxBlockingObservable(Operators)
//  RxObjC
// 
//  Created by Pavel Malkov on 13.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxBlockingObservable+Operators.h"
#import "RxRunLoopLock.h"

@implementation RxBlockingObservable (ToArray)

- (nonnull NSArray *)blocking_toArray {
    NSMutableArray *elements = [NSMutableArray array];
    __block NSError *error = nil;

    RxRunLoopLock *lock = [[RxRunLoopLock alloc] init];
    
    RxSingleAssignmentDisposable *d = [[RxSingleAssignmentDisposable alloc] init];

    @weakify(self);
    [lock dispatch:^{
        @strongify(self);
        d.disposable = [self.source subscribeWith:^(RxEvent *__nonnull event) {
            if (d.disposed) {
                return;
            }
            
            switch (event.type) {
                case RxEventTypeNext: {
                    [elements addObject:event.element];
                    break;
                }
                case RxEventTypeError: {
                    error = event.error;
                    [d dispose];
                    [lock stop];
                    break;
                }
                case RxEventTypeCompleted: {
                    [d dispose];
                    [lock stop];
                    break;
                }
            }
        }];
    }];

    [lock run];

    [d dispose];
    
    if (error) {
        @throw error;
    }
    
    return [elements copy];
}

@end

@implementation RxBlockingObservable (First)

- (nullable id)blocking_first {
    __block id element = nil;
    __block NSError *error = nil;

    RxSingleAssignmentDisposable *d = [[RxSingleAssignmentDisposable alloc] init];

    RxRunLoopLock *lock = [[RxRunLoopLock alloc] init];

    @weakify(self);
    [lock dispatch:^{
        @strongify(self);
        d.disposable = [self.source subscribeWith:^(RxEvent *__nonnull event) {
            if ([d disposed]) {
                return;
            }

            switch (event.type) {
                case RxEventTypeNext: {
                    if (!element) {
                        element = event.element;
                    }
                    break;
                }
                case RxEventTypeError: {
                    error = event.error;
                    break;
                }
                case RxEventTypeCompleted: {
                    break;
                }
            }
            [d dispose];
            [lock stop];
        }];
    }];

    [lock run];

    [d dispose];

    if (error) {
        @throw error;
    }

    return element;
}

@end

@implementation RxBlockingObservable (Last)

- (nullable id)blocking_last {
    __block id element = nil;
    __block NSError *error = nil;

    RxSingleAssignmentDisposable *d = [[RxSingleAssignmentDisposable alloc] init];

    RxRunLoopLock *lock = [[RxRunLoopLock alloc] init];

    @weakify(self);
    [lock dispatch:^{
        @strongify(self);
        d.disposable = [self.source subscribeWith:^(RxEvent *__nonnull event) {
            if ([d disposed]) {
                return;
            }

            switch (event.type) {
                case RxEventTypeNext: {
                    element = event.element;
                    break;
                }
                case RxEventTypeError: {
                    error = event.error;
                    [d dispose];
                    [lock stop];
                    break;
                }
                case RxEventTypeCompleted: {
                    [d dispose];
                    [lock stop];
                    break;
                }
            }
        }];
    }];

    [lock run];

    [d dispose];

    if (error) {
        @throw error;
    }

    return element;
}

@end

@implementation RxBlockingObservable (Single)

- (nullable id)blocking_single {
    return [self blocking_single:^BOOL(id o) {
        return YES;
    }];
}

- (nullable id)blocking_single:(nonnull BOOL(^)(id __nullable))predicate {
    __block id element = nil;
    __block NSError *error = nil;

    RxSingleAssignmentDisposable *d = [[RxSingleAssignmentDisposable alloc] init];

    RxRunLoopLock *lock = [[RxRunLoopLock alloc] init];

    @weakify(self);
    [lock dispatch:^{
        @strongify(self);
        d.disposable = [self.source subscribeWith:^(RxEvent *__nonnull event) {
            if ([d disposed]) {
                return;
            }

            switch (event.type) {
                case RxEventTypeNext: {
                    rx_tryCatch(^{
                        if (!predicate(event.element)) {
                            return;
                        }
                        if (!element) {
                            element = event.element;
                        } else {
                            @throw [RxError moreThanOneElement];
                        }
                    }, ^(NSError *e) {
                        error = e;
                        [d dispose];
                        [lock stop];
                    });
                    break;
                }
                case RxEventTypeError: {
                    error = event.error;
                    [d dispose];
                    [lock stop];
                    break;
                }
                case RxEventTypeCompleted: {
                    if (!element) {
                        error = [RxError noElements];
                    }
                    [d dispose];
                    [lock stop];
                    break;
                }
            }
        }];
    }];

    [lock run];

    [d dispose];

    if (error) {
        @throw error;
    }

    return element;
}

@end