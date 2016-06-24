//
//  RxShareReplay1
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservable.h"
#import "RxSynchronizedUnsubscribeType.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxShareReplay1<Element> : RxObservable<Element> <RxObserverType, RxSynchronizedUnsubscribeType>

- (nonnull instancetype)initWithSource:(nonnull RxObservable<Element> *)observable;

@end

NS_ASSUME_NONNULL_END