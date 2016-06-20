//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"
#import "RxObservableBlockTypedef.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxReduce<ResultType> : RxProducer<ResultType> {
@package
    RxObservable<RxSourceType> *__nonnull _source;
    RxAccumulateType __nonnull _seed;
    RxAccumulatorType __nonnull _accumulator;
    ResultSelectorType __nonnull _mapResult;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<RxSourceType> *)source
                                  seed:(nonnull RxAccumulateType)seed
                           accumulator:(nonnull RxAccumulatorType)accumulator
                             mapResult:(nonnull ResultSelectorType)mapResult;
@end

NS_ASSUME_NONNULL_END