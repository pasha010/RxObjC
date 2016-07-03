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

@interface RxFlatMap<Element> : RxProducer<Element>

- (nonnull instancetype)initWithSource:(nonnull RxObservable<Element> *)source
                              selector:(RxFlatMapSelector)selector;

@end

@interface RxFlatMapWithIndex<Element> : RxProducer<Element>

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source selector:(RxFlatMapWithIndexSelector)aSelector;

@end

@interface RxFlatMapFirst<Element> : RxProducer<Element>

- (nonnull instancetype)initWithSource:(nonnull RxObservable<Element> *)source
                              selector:(RxFlatMapSelector)selector;

@end

NS_ASSUME_NONNULL_END