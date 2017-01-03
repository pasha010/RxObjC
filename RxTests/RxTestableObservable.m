//
//  RxTestableObservable.m
//  RxObjC
// 
//  Created by Pavel Malkov on 21.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTestableObservable.h"
#import "RxTestScheduler.h"
#import "RxObjCCommon.h"
#import "RxAnyObserver.h"
#import "RxObservable+Creation.h"

@implementation RxTestableObservable

- (nonnull instancetype)initWithTestScheduler:(nonnull RxTestScheduler *)testScheduler
                               recordedEvents:(nonnull NSArray<RxRecorded<RxEvent<id> *> *> *)recordedEvents {
    self = [super init];
    if (self) {
        _testScheduler = testScheduler;
        _recordedEvents = recordedEvents;
        _subscriptions = [NSMutableArray array];
    }
    return self;
}

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    // 
    return nil;
}

- (nonnull RxObservable *)asObservable {
    return [RxObservable create:^id <RxDisposable>(RxAnyObserver *observer) {
        return [self subscribe:observer];
    }];
}

@end