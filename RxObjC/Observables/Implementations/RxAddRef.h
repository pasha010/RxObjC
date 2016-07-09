//
//  RxAddRef
//  RxObjC
// 
//  Created by Pavel Malkov on 09.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

@class RxRefCountDisposable;

NS_ASSUME_NONNULL_BEGIN

@interface RxAddRef<Element> : RxProducer<Element> {
@package
    RxObservable<Element> *__nonnull _source;
    RxRefCountDisposable *__nonnull _refCount;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<Element> *)source
                              refCount:(nonnull RxRefCountDisposable *)refCount;

@end

NS_ASSUME_NONNULL_END