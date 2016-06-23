//
//  RxErrorProducer
//  RxObjC
// 
//  Created by Pavel Malkov on 23.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxErrorProducer<Element> : RxProducer<Element>

+ (nonnull instancetype)error:(nonnull NSError *)error;

- (nonnull instancetype)initWithError:(nonnull NSError *)error;

@end

NS_ASSUME_NONNULL_END