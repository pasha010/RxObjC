//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
Sequence that repeats `repeatedValue` infinite number of times.
*/
@interface RxInfiniteSequence<ObjectType> : NSEnumerator<ObjectType>

- (nonnull instancetype)initWithRepeatedValue:(nonnull ObjectType)repeatedValue;

@end

NS_ASSUME_NONNULL_END