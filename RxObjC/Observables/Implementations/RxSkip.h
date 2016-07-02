//
//  RxSkip
//  RxObjC
// 
//  Created by Pavel Malkov on 02.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxSkipCount<Element> : RxProducer<Element> {
@package
    RxObservable *__nonnull _source;
    NSInteger _count;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source count:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END