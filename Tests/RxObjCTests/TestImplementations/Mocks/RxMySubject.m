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
#import "RxObservable+Creation.h"

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

    return [[RxAnonymousDisposable alloc] initWithDisposeAction:^{
        self->_observer = [[RxAnyObserver alloc] initWithEventHandler:^(RxEvent *_) {

        }];
        self->_disposed = YES;
    }];
}

- (nonnull RxObservable *)asObservable {
    return [RxObservable create:^id <RxDisposable>(RxAnyObserver *observer) {
        return [self subscribe:observer];
    }];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"

- (nonnull instancetype)asObserver {
    return self;
}

#pragma clang diagnostic pop
@end