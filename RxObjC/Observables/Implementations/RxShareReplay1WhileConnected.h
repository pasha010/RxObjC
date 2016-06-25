//
//  RxShareReplay1WhileConnected
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservable.h"
#import "RxSynchronizedUnsubscribeType.h"

NS_ASSUME_NONNULL_BEGIN

// optimized version of share replay for most common case
@interface RxShareReplay1WhileConnected<Element> : RxObservable<Element> <RxObserverType, RxSynchronizedUnsubscribeType>

- (nonnull instancetype)initWithSource:(nonnull RxObservable<Element> *)source;


@end

NS_ASSUME_NONNULL_END