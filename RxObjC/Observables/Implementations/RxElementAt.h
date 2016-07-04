//
//  RxElementAt
//  RxObjC
// 
//  Created by Pavel Malkov on 04.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxElementAt<Element> : RxProducer<Element> {
@package
    RxObservable<Element> *__nonnull _source;
    NSUInteger _index;
    BOOL _throwOnEmpty;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<Element> *)source index:(NSUInteger)index throwOnEmpty:(BOOL)throwOnEmpty;

@end

NS_ASSUME_NONNULL_END