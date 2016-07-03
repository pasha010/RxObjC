//
//  RxSwitch
//  RxObjC
// 
//  Created by Pavel Malkov on 03.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxSwitch<S : id <RxObservableConvertibleType>> : RxProducer

- (nonnull instancetype)initWithSource:(nonnull RxObservable<S> *)source;

@end

@interface RxFlatMapLatest<Element> : RxProducer<Element>

- (nonnull instancetype)initWithSource:(nonnull RxObservable<Element> *)source
                              selector:(RxFlatMapSelector)selector;

@end

NS_ASSUME_NONNULL_END