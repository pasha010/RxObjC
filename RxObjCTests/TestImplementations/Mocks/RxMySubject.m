//
//  RxMySubject
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxMySubject.h"
#import "RxAnyObserver.h"
#import "RxAnonymousDisposable.h"

@implementation RxMySubject {
    NSMutableDictionary<id, id <RxDisposable>> *__nonnull _disposeOn;
    RxAnyObserver *__nullable _observer;
}

+ (nonnull instancetype)create {
    return [[self alloc] init];
}

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _disposeOn = [NSMutableDictionary dictionary];
        _observer = nil;
        _subscribeCount = 0;
        _disposed = NO;
    }
    return self;
}

- (void)disposeOn:(nonnull id)value disposable:(nonnull id <RxDisposable>)disposable {
    _disposeOn[value] = disposable;
}

- (void)on:(nonnull RxEvent *)event {
    [_observer on:event];
    if (event.type == RxEventTypeNext) {
        id <RxDisposable> disposable = _disposeOn[event.element];
        if (disposable) {
            [disposable dispose];
        }
    }
}

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    _subscribeCount++;
    _observer = [[RxAnyObserver alloc] initWithObserver:observer];

    @weakify(self);
    return [[RxAnonymousDisposable alloc] initWithDisposeAction:^{
        @strongify(self);
        self->_observer = [[RxAnyObserver alloc] initWithEventHandler:^(RxEvent *_) {

        }];
        self->_disposed = YES;
    }];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"

- (nonnull instancetype)asObserver {
    return self;
}

#pragma clang diagnostic pop
@end