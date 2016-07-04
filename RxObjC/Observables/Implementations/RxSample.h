//
//  RxSample
//  RxObjC
// 
//  Created by Pavel Malkov on 04.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxSample<Element> : RxProducer<Element> {
@package
    RxObservable<Element> *__nonnull _source;
    RxObservable<Element> *__nonnull _sampler;
    BOOL _onlyNew;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<Element> *)source sampler:(nonnull RxObservable<Element> *)sampler onlyNew:(BOOL)onlyNew;


@end

NS_ASSUME_NONNULL_END