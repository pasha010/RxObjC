//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable+Aggregate.h"
#import "RxReduce.h"
#import "RxToArray.h"

@implementation RxObservable (Aggregate)

- (nonnull RxObservable<id> *)reduce:(id)seed accumulator:(RxAccumulatorType)accumulator mapResult:(ResultSelectorType)mapResult {
    return [[RxReduce alloc] initWithSource:[self asObservable] seed:seed accumulator:accumulator mapResult:mapResult];
}

- (nonnull RxObservable<id> *)reduce:(id)seed accumulator:(RxAccumulatorType)accumulator {
    return [[RxReduce alloc] initWithSource:[self asObservable] seed:seed accumulator:accumulator mapResult:^id(id obj) {return obj;}];
}

- (nonnull RxObservable<NSArray<id> *> *)toArray {
    return [[RxToArray alloc] initWithSource:[self asObservable]];
}

@end