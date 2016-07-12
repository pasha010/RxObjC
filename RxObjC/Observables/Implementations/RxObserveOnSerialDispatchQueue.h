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

/**
Counts number of `SerialDispatchQueueObservables`.

Purposed for unit tests.
*/
#if TRACE_RESOURCES
static int32_t rx_numberOfSerialDispatchQueueObservables = 0;
#endif

@interface RxObserveOnSerialDispatchQueue<Element> : RxProducer<Element> {
@package
    RxObservable *__nonnull _source;
    RxSerialDispatchQueueScheduler *__nonnull _scheduler;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<Element> *)source
                             scheduler:(nonnull RxSerialDispatchQueueScheduler *)scheduler;

@end

NS_ASSUME_NONNULL_END