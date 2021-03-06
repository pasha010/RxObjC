//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservable.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxProducer<Element> : RxObservable<Element>

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer;

@end

NS_ASSUME_NONNULL_END