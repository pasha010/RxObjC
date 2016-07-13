//
//  RxHotObservable
//  RxObjC
// 
//  Created by Pavel Malkov on 21.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxHotObservable.h"
#import "RxTestScheduler.h"
#import "RxBag.h"
#import "RxAnyObserver.h"
#import "RxSubscription.h"
#import "RxAnonymousDisposable.h"

@implementation RxHotObservable {
    /**
     Current subscribed observers.
    */
    RxBag<RxAnyObserver<id> *> *__nonnull _observers;
}

- (nonnull instancetype)initWithTestScheduler:(nonnull RxTestScheduler *)testScheduler
                               recordedEvents:(nonnull NSArray<RxRecorded<RxEvent<id> *> *> *)recordedEvents {
    self = [super initWithTestScheduler:testScheduler recordedEvents:recordedEvents];
    if (self) {
        _observers = [[RxBag alloc] init];
        for (RxRecorded<RxEvent<id> *> *recordedEvent in recordedEvents) {
            [testScheduler scheduleAt:recordedEvent.time action:^{
                [_observers on:recordedEvent.value];
            }];
        }
    }

    return self;
}

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    __block RxBagKey *key = [_observers insert:[[RxAnyObserver alloc] initWithObserver:observer]];

    [self.subscriptions addObject:[[RxSubscription alloc] initWithSubscribe:((NSNumber *) self.testScheduler.clock).unsignedIntegerValue]];

    __block NSUInteger i = self.subscriptions.count - 1;
    @weakify(self);
    return [[RxAnonymousDisposable alloc] initWithDisposeAction:^{
        @strongify(self);
        RxAnyObserver *removed = [self->_observers removeKey:key];
        NSAssert(removed != nil, @"");

        RxSubscription *existing = self.subscriptions[i];
        self.subscriptions[i] = [[RxSubscription alloc] initWithSubscribe:existing.subscribe
                                                              unsubscribe:((NSNumber *) self.testScheduler.clock).unsignedIntegerValue];
    }];
}


@end