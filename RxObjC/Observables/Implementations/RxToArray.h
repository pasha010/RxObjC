//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservable.h"
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxToArray<SourceType> : RxProducer<NSArray<SourceType> *>

- (nonnull instancetype)initWithSource:(nonnull RxObservable<SourceType> *)source;

@end

NS_ASSUME_NONNULL_END