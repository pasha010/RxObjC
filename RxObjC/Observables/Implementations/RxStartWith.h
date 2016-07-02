//
//  RxStartWith
//  RxObjC
// 
//  Created by Pavel Malkov on 28.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxStartWith<Element> : RxProducer<Element>

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source elements:(nonnull NSArray *)elements;

@end

NS_ASSUME_NONNULL_END