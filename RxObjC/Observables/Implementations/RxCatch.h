//
//  RxCatch
//  RxObjC
// 
//  Created by Pavel Malkov on 28.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxCatch<Element> : RxProducer<Element> {
@package
    RxObservable *_source;
    RxCatchHandler _handler;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<Element> *)source handler:(RxCatchHandler)handler;


@end

@interface RxCatchSequence<Element> : RxProducer<Element> {
@package
    NSEnumerator *__nonnull _sources;
}

- (nonnull instancetype)initWithSources:(nonnull NSEnumerator *)sources;

@end

NS_ASSUME_NONNULL_END