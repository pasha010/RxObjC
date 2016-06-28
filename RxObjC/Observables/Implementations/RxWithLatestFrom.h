//
//  RxWithLatestFrom
//  RxObjC
// 
//  Created by Pavel Malkov on 28.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxWithLatestFrom<FirstType, SecondType, ResultType> : RxProducer<ResultType> {
@package
    RxObservable *__nonnull _first;
    RxObservable *__nonnull _second;
    RxWithLatestFromResultSelector _resultSelector;
}

- (nonnull instancetype)initWithFirst:(nonnull RxObservable *)first
                               second:(nonnull RxObservable *)second
                       resultSelector:(RxWithLatestFromResultSelector)resultSelector;


@end

NS_ASSUME_NONNULL_END