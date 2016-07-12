//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObjCCommon.h"
#import "RxDisposable.h"
#import "RxObserverType.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxObserverBase<ElementType> : NSObject <RxDisposable, RxObserverType>

- (void)_onCore:(nonnull RxEvent<ElementType> *)event;

@end

NS_ASSUME_NONNULL_END