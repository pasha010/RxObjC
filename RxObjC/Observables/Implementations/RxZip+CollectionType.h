//
//  RxZip(CollectionType)
//  RxObjC
// 
//  Created by Pavel Malkov on 04.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxZipCollectionType<C : id <RxObservableConvertibleType>, Element> : RxProducer<Element> {
@package
    NSArray<C> *__nonnull _sources;
    RxZipCollectionTypeResultSelector _resultSelector;
    NSUInteger _count;
}

- (nonnull instancetype)initWithSources:(nonnull NSArray<C> *)sources
                         resultSelector:(RxZipCollectionTypeResultSelector)resultSelector;


@end

NS_ASSUME_NONNULL_END