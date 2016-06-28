//
//  RxSkipUntil
//  RxObjC
// 
//  Created by Pavel Malkov on 28.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxSkipUntil<Element, Other> : RxProducer<Element> {
@package
    RxObservable *__nonnull _source;
    RxObservable *__nonnull _other;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source other:(nonnull RxObservable *)other;

@end

NS_ASSUME_NONNULL_END