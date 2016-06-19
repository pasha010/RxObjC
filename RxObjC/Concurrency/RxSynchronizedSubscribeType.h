//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservableType.h"
#import "RxLock.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RxSynchronizedSubscribeType <RxObservableType, RxLock>

- (nonnull id <RxDisposable>)_synchronized_subscribe:(nonnull id <RxObserverType>)observer;

@end

@interface NSObject (RxSynchronizedSubscribeType) <RxSynchronizedSubscribeType>

- (nonnull id <RxDisposable>)synchronizedSubscribe:(nonnull id <RxObserverType>)observer;


@end

NS_ASSUME_NONNULL_END