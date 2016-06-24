//
//  RxConcat
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

@protocol RxObservableConvertibleType;

NS_ASSUME_NONNULL_BEGIN

@interface RxConcat : RxProducer {
@package
    NSEnumerator<id <RxObservableConvertibleType>> *__nonnull _sources;
    NSUInteger _count;
}

- (nonnull instancetype)initWithSources:(nonnull NSEnumerator<id <RxObservableConvertibleType>> *)sources;

- (nonnull instancetype)initWithSources:(nonnull NSEnumerator<id <RxObservableConvertibleType>> *)sources
                                  count:(NSUInteger)count;

@end

NS_ASSUME_NONNULL_END