//
//  RxScan
//  RxObjC
// 
//  Created by Pavel Malkov on 02.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxScan<Element, Accumulate> : RxProducer<Accumulate> {
@package
    RxObservable<Element> *__nonnull _source;
    Accumulate __nonnull _seed;
    RxScanAccumulator _accumulator;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<Element> *)source
                                  seed:(nonnull Accumulate)seed
                           accumulator:(RxScanAccumulator)accumulator;


@end

NS_ASSUME_NONNULL_END