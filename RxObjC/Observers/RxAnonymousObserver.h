//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObserverBase.h"
#import "RxObjCCommon.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxAnonymousObserver<ElementType> : RxObserverBase<ElementType>

- (nonnull instancetype)initWithEventHandler:(nonnull RxEventHandler)eventHandler;

@end

NS_ASSUME_NONNULL_END