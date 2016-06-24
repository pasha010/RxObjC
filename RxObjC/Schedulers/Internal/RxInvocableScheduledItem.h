//
//  RxInvocableScheduledItem
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxInvocableType.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxInvocableScheduledItem<I : id <RxInvocableWithValueType>> : NSObject <RxInvocableType>

- (nonnull instancetype)initWithInvocable:(nonnull id <RxInvocableWithValueType>)invocable state:(nonnull id)state;

@end

NS_ASSUME_NONNULL_END