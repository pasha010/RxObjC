//
//  RxDo
//  RxObjC
// 
//  Created by Pavel Malkov on 28.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxDo<Element> : RxProducer<Element> {
@package
    RxObservable *__nonnull _source;
    RxDoOnEventHandler __nonnull _eventHandler;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source eventHandler:(nonnull RxDoOnEventHandler)eventHandler;


@end

NS_ASSUME_NONNULL_END