//
//  RxDistinctUntilChanged
//  RxObjC
// 
//  Created by Pavel Malkov on 28.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxDistinctUntilChanged<Element> : RxProducer<Element> {
@package
    RxObservable *__nonnull _source;
    RxDistinctUntilChangedKeySelector _selector;
    RxDistinctUntilChangedEqualityComparer _comparer;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source
                           keySelector:(RxDistinctUntilChangedKeySelector)keySelector
                              comparer:(RxDistinctUntilChangedEqualityComparer)comparer;


@end

NS_ASSUME_NONNULL_END