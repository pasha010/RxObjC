//
//  RxObserveOnSerialDispatchQueue
//  RxObjC
// 
//  Created by Pavel Malkov on 26.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"
#import "RxObjCCommon.h"

@class RxSerialDispatchQueueScheduler;

NS_ASSUME_NONNULL_BEGIN

@interface RxObserveOnSerialDispatchQueue<Element> : RxProducer<Element> {
@package
    RxObservable *__nonnull _source;
    RxSerialDispatchQueueScheduler *__nonnull _scheduler;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<Element> *)source
                             scheduler:(nonnull RxSerialDispatchQueueScheduler *)scheduler;

@end

NS_ASSUME_NONNULL_END