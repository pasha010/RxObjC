//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxProducer.h"
#import "RxObjCCommon.h"
#import "RxCurrentThreadScheduler.h"


@implementation RxProducer

- (id <RxDisposable>)subscribe:(id <RxObserverType>)observer {
    if (![RxCurrentThreadScheduler sharedInstance].isScheduleRequired) {
        return [self run:observer];
    } else {
        return [[RxCurrentThreadScheduler sharedInstance] schedule:nil action:^id <RxDisposable>(RxStateType _) {
            return [self run:observer];
        }];
    }
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    return rx_abstractMethod();
}

@end