//
//  RxMaybe
//  RxObjC
// 
//  Created by Pavel Malkov on 30.08.17.
//  Copyright (c) 2014-2017 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxPrimitiveSequence.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT RxPrimitiveTrait const RxPrimitiveTraitMaybe;

/**
 * Represents a push style sequence containing 0 or 1 element.
 */
@interface RxMaybe<__covariant Element> : RxPrimitiveSequence<Element>
@end

@interface RxMaybe<__covariant Element> (Creation)

@end

@interface RxMaybe<__covariant Element> (Extension)

/**
 * Returns an empty observable sequence, using the specified scheduler to send out the single `Completed` message.
 * @return
 */
+ (nonnull instancetype)empty;

@end

@interface RxObservable<__covariant Element> (AsMaybe)

/**
 * The `asMaybe` operator throws a ``RxError.moreThanOneElement`
 * if the source Observable does not emit at most one element before successfully completing.
 * @return An observable sequence that emits a single element, completes or throws an exception if more of them are emitted.
 */
- (nonnull RxMaybe<Element> *)asMaybe;

@end

@interface RxMaybeEvent : NSObject

@property (readonly) BOOL isSuccess;
@property (readonly) BOOL isError;
@property (readonly) BOOL isCompleted;

@end

@interface RxMaybeEventSuccess<__covariant Element> : RxMaybeEvent

@property (nullable, strong, readonly) Element element;

+ (nonnull instancetype)success:(nullable Element)element;

@end

@interface RxMaybeEventError : RxMaybeEvent

@property (nullable, strong, readonly) NSError *error;

+ (nonnull instancetype)error:(NSError *)error;

@end

@interface RxMaybeEventCompleted : RxMaybeEvent

+ (nonnull instancetype)completed;

@end

NS_ASSUME_NONNULL_END