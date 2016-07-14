//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObserverType.h"
#import "RxSingleAssignmentDisposable.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxSink<__covariant O : id <RxObserverType>> : RxSingleAssignmentDisposable {
@package
    id <RxObserverType> __nonnull _observer;
}

- (nonnull instancetype)initWithObserver:(nonnull O)observer;

- (void)forwardOn:(nonnull RxEvent<O> *)event;

- (nonnull O)forwarder;

@end

NS_ASSUME_NONNULL_END