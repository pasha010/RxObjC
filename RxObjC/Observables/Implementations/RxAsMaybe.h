//
//  RxAsMaybe
//  RxObjC
// 
//  Created by Pavel Malkov on 31.08.17.
//  Copyright (c) 2014-2017 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxAsMaybe<__covariant Element> : RxProducer<Element>

- (nonnull instancetype)initWithSource:(RxObservable<Element> *)source;

@end

NS_ASSUME_NONNULL_END