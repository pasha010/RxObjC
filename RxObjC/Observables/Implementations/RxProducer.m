//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxProducer.h"
#import "RxObjC.h"
#import "RxCurrentThreadScheduler.h"


@implementation RxProducer

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (id <RxDisposable>)subscribe:(id <RxObserverType>)observer {
    if (![RxCurrentThreadScheduler sharedInstance].isScheduleRequired) {
        return [self run:observer];
    } else {
        @weakify(self);
        return [[RxCurrentThreadScheduler sharedInstance] schedule:nil action:^id <RxDisposable>(RxStateType _) {
            @strongify(self);
            return [self run:observer];
        }];
    }
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    rx_abstractMethod();
    return nil;
}

@end