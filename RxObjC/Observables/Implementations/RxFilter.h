//
//  RxFilter
//  RxObjC
// 
//  Created by Pavel Malkov on 02.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxFilter<Element> : RxProducer<Element>

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source predicate:(RxFilterPredicate)predicate;


@end

NS_ASSUME_NONNULL_END