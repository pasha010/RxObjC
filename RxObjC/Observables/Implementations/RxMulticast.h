//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"
#import "RxObservableBlockTypedef.h"

@protocol RxSubjectType;

NS_ASSUME_NONNULL_BEGIN

@interface RxMulticast<S : id <RxSubjectType>, R> : RxProducer<R> {
@package
    RxObservable *__nonnull _source;
    RxSubjectSelectorType _subjectSelector;
    RxSelectorType _sel;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source
                       subjectSelector:(RxSubjectSelectorType)subjectSelector
                              selector:(RxSelectorType)sel;
@end

NS_ASSUME_NONNULL_END