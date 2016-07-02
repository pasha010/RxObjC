//
//  RxTakeWhile
//  RxObjC
// 
//  Created by Pavel Malkov on 02.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxTakeWhile<Element> : RxProducer<Element> {
@package
    RxObservable<Element> *__nonnull _source;
    RxTakeWhilePredicate __nullable _predicate;
    RxTakeWhileWithIndexPredicate __nullable _indexPredicate;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source
                             predicate:(RxTakeWhilePredicate)predicate;

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source
                        indexPredicate:(RxTakeWhileWithIndexPredicate)indexPredicate;


@end

NS_ASSUME_NONNULL_END