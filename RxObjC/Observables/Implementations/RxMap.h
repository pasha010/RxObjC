//
//  RxMap
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxMap<SourceType, ResultType> : RxProducer<ResultType>

- (nonnull instancetype)initWithSource:(nonnull RxObservable<SourceType> *)observable selector:(RxMapSelector)selector;

@end

@interface RxMapWithIndex<SourceType, ResultType> : RxProducer<ResultType>

- (nonnull instancetype)initWithSource:(nonnull RxObservable<SourceType> *)observable selector:(RxMapWithIndexSelector)selector;

@end

NS_ASSUME_NONNULL_END