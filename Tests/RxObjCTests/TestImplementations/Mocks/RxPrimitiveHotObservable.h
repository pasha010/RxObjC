//
//  RxPrimitiveHotObservable
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxSubscription.h"
#import "RxObjC.h"

NS_ASSUME_NONNULL_BEGIN

extern RxSubscription *RxSubscribedToHotObservable();
extern RxSubscription *RxUnsunscribedFromHotObservable();

@interface RxPrimitiveHotObservable : NSObject <RxObservableType>

@property (nonnull, nonatomic, strong, readonly) NSArray<RxSubscription *> *subscriptions;
@property (nonnull, nonatomic, strong, readonly) RxBag<RxAnyObserver *> *observers;

- (nonnull instancetype)init;

@end

NS_ASSUME_NONNULL_END