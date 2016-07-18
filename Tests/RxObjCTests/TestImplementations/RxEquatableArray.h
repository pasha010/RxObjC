//
//  RxEquatableArray
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RxEquatableArray<E> : NSObject

- (instancetype)initWithElements:(NSArray<E> *)elements;

FOUNDATION_EXTERN RxEquatableArray *EquatableArray(NSArray<E> *elements);

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToArray:(RxEquatableArray<E> *)array;

- (NSUInteger)hash;


@end

NS_ASSUME_NONNULL_END