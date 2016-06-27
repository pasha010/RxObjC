//
//  RxMerge
//  RxObjC
// 
//  Created by Pavel Malkov on 26.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxMerge<S : id <RxObservableConvertibleType>> : RxProducer<id>

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source;

@end

@interface RxMergeLimited<S : id<RxObservableConvertibleType>> : RxProducer<id>

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source maxConcurrent:(NSUInteger)maxConcurrent;
@end

NS_ASSUME_NONNULL_END