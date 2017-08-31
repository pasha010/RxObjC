//
//  RxCompletable
//  RxObjC
// 
//  Created by Pavel Malkov on 30.08.17.
//  Copyright (c) 2014-2017 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxPrimitiveSequence.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT RxPrimitiveTrait const RxPrimitiveTraitCompletable;

/**
 * Represents a push style sequence containing 0 elements.
 */
@interface RxCompletable : RxPrimitiveSequence
@end

@interface RxObservable<__covariant Element> (AsCompletable)

- (nonnull RxCompletable *)asCompletable;

@end

NS_ASSUME_NONNULL_END