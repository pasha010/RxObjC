//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
Creates mutable reference wrapper for any type.
*/
@interface RxMutableBox<__covariant T> : NSObject

/**
Wrapped value
*/
@property (nonnull, strong, atomic) T value;

/**
Creates reference wrapper for `value`.

- parameter value: Value to wrap.
*/
- (nonnull instancetype)initWithValue:(nonnull T)value;

@end

NS_ASSUME_NONNULL_END