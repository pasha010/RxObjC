//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RxError : NSError

/**
Unknown error occured.
*/
+ (nonnull instancetype)unknown;

/**
Performing an action on disposed object.
*/
+ (nonnull instancetype)disposedObject:(nonnull id)object;

/**
Aritmetic overflow error.
*/
+ (nonnull instancetype)overflow;

/**
Argument out of range error.
*/
+ (nonnull instancetype)argumentOutOfRange;

/**
Sequence doesn't contain any elements.
*/
+ (nonnull instancetype)noElements;

/**
Sequence contains more than one element.
*/
+ (nonnull instancetype)moreThanOneElement;

/**
 Timeout error.
 */
+ (nonnull instancetype)timeout;

@end

NS_ASSUME_NONNULL_END