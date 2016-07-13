//
//  RxColdObservable
//  RxObjC
// 
//  Created by Pavel Malkov on 21.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxColdObservable.h"
#import "RxSubscription.h"
#import "RxTestScheduler.h"
#import "RxNopDisposable.h"
#import "RxAnonymousDisposable.h"

@implementation RxColdObservable

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    [self.subscriptions addObject:[[RxSubscription alloc] initWithSubscribe:((NSNumber *) self.testScheduler.clock).unsignedIntegerValue]];

    __block NSUInteger i = self.subscriptions.count - 1;

    for (RxRecorded<RxEvent<id> *> * recordedEvent in self.recordedEvents) {
        [self.testScheduler scheduleRelativeVirtual:nil dueTime:recordedEvent.time action:^id <RxDisposable>(id o) {
            [observer on:recordedEvent.value];
            return [RxNopDisposable sharedInstance];
        }];
    }
    
    return [[RxAnonymousDisposable alloc] initWithDisposeAction:^{
        RxSubscription *existing = self.subscriptions[i];
        self.subscriptions[i] = [[RxSubscription alloc] initWithSubscribe:existing.subscribe
                                                              unsubscribe:((NSNumber *) self.testScheduler.clock).unsignedIntegerValue];
    }];
}

@end