//
//  RxAnonymousObservable
//  RxObjC
// 
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservableBlockTypedef.h"
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxAnonymousObservable<Element> : RxProducer<Element>

@property (copy, readonly) RxAnonymousSubscribeHandler subscribeHandler;

- (nonnull instancetype)initWithSubscribeHandler:(RxAnonymousSubscribeHandler)subscribeHandler;

@end

NS_ASSUME_NONNULL_END