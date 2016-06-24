//
//  RxEmpty
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservable.h"
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxEmpty<Element> : RxProducer<Element>

@end

NS_ASSUME_NONNULL_END