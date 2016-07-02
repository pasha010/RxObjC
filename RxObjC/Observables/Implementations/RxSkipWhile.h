//
//  RxSkipWhile
//  RxObjC
// 
//  Created by Pavel Malkov on 02.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxSkipWhile<Element> : RxProducer<Element> {
@package
    RxObservable<Element> *__nonnull _source;
    RxSkipWhilePredicate __nullable _predicate;
    RxSkipWhileWithIndexPredicate __nullable _indexPredicate;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source
                             predicate:(RxSkipWhilePredicate)predicate;

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source
                        indexPredicate:(RxSkipWhileWithIndexPredicate)indexPredicate;


@end

NS_ASSUME_NONNULL_END