//
//  RxPrimitiveHotObservable
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxPrimitiveHotObservable.h"
#import "RxBag.h"
#import "RxAnyObserver.h"
#import "RxLock.h"
#import "RxAnonymousDisposable.h"

RxSubscription *RxSubscribedToHotObservable() {
    static RxSubscription *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
       instance = [[RxSubscription alloc] initWithSubscribe:0];
    });
    return instance;
}

RxSubscription *RxUnsunscribedFromHotObservable() {
    static RxSubscription *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[RxSubscription alloc] initWithSubscribe:0 unsubscribe:0];
    });
    return instance;
}

@implementation RxPrimitiveHotObservable {
    NSMutableArray<RxSubscription *> *__nonnull _subscriptions;
    NSRecursiveLock *__nonnull _lock;
}

@synthesize subscriptions = _subscriptions;

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _subscriptions = [NSMutableArray array];
        _observers = [[RxBag alloc] init];
        _lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    [_lock lock];
    [self.observers on:event];
    [_lock unlock];
}

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    return [_lock calculateLocked:^id <RxDisposable> {
        RxBagKey *key = [self.observers insert:[[RxAnyObserver alloc] initWithObserver:observer]];
        [_subscriptions addObject:RxSubscribedToHotObservable()];

        NSUInteger i = self.subscriptions.count - 1;
        
        return [[RxAnonymousDisposable alloc] initWithDisposeAction:^{
            [_lock lock];

            RxAnyObserver *removed = [self.observers removeKey:key];

            NSAssert(removed != nil, @"removed not nullable");

            _subscriptions[i] = RxUnsunscribedFromHotObservable();
            
            [_lock unlock];
        }];
    }];
}

@end