//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RxError : NSError

//! Unknown error occured.
@property (class, nonnull, nonatomic, readonly) RxError *unknown;

//! Arifmetic overflow error.
@property (class, nonnull, nonatomic, readonly) RxError *overflow;

//! Argument out of range error.
@property (class, nonnull, nonatomic, readonly) RxError *argumentOutOfRange;

//! Sequence doesn't contain any elements.
@property (class, nonnull, nonatomic, readonly) RxError *noElements;

//! Sequence contains more than one element.
@property (class, nonnull, nonatomic, readonly) RxError *moreThanOneElement;

//! Timeout error.
@property (class, nonnull, nonatomic, readonly) RxError *timeout;

//! Performing an action on disposed object.
+ (nonnull instancetype)disposedObject:(nonnull id)object;

@end

NS_ASSUME_NONNULL_END