//
//  RxSingleAsync
//  RxObjC
// 
//  Created by Pavel Malkov on 04.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxSingleAsync<Element> : RxProducer<Element> {
@package
    RxObservable<Element> *__nonnull _source;
    RxSingleAsyncPredicate __nullable _predicate;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source;

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source predicate:(nullable RxSingleAsyncPredicate)predicate;


@end

NS_ASSUME_NONNULL_END