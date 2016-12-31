//
//  RxGenerate
//  RxObjC
// 
//  Created by Pavel Malkov on 25.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

@class RxImmediateScheduler;

NS_ASSUME_NONNULL_BEGIN

@interface RxGenerate<S, E> : RxProducer<E> {
@package
    id __nonnull _initialState;
    BOOL (^_condition)(id);
    id (^_iterate)(id);
    id (^_resultSelector)(id);
    RxImmediateScheduler *__nonnull _scheduler;
}

- (nonnull instancetype)initWithInitialState:(nonnull S)initialState
                                   condition:(BOOL (^)(S))condition
                                     iterate:(S (^)(S))iterate
                              resultSelector:(E (^)(S))resultSelector
                                   scheduler:(nonnull RxImmediateScheduler *)scheduler;
@end

NS_ASSUME_NONNULL_END