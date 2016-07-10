//
//  RxPrimitiveHotObservable
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservable.h"
#import "RxSubscription.h"

NS_ASSUME_NONNULL_BEGIN

extern RxSubscription *RxSubscribedToHotObservable();
extern RxSubscription *RxUnsunscribedFromHotObservable();

@interface RxPrimitiveHotObservable : NSObject <RxObservableType>
- (nonnull instancetype)init;

@end

NS_ASSUME_NONNULL_END