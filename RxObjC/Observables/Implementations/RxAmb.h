//
//  RxAmb
//  RxObjC
// 
//  Created by Pavel Malkov on 28.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxAmb<Element> : RxProducer<Element> {
@package
    RxObservable *__nonnull _left;
    RxObservable *__nonnull _right;
}

- (nonnull instancetype)initWithLeft:(nonnull RxObservable *)left right:(nonnull RxObservable *)right;


@end

NS_ASSUME_NONNULL_END