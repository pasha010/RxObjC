//
//  RxNever
//  RxObjC
// 
//  Created by Pavel Malkov on 25.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxNever<Element> : RxProducer<Element>

- (nonnull instancetype)init;

@end

NS_ASSUME_NONNULL_END