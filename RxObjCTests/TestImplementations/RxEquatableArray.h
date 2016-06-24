//
//  RxEquatableArray
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RxEquatableArray : NSObject

- (instancetype)initWithElements:(NSArray *)elements;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToArray:(RxEquatableArray *)array;

- (NSUInteger)hash;


@end

NS_ASSUME_NONNULL_END