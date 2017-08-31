//
//  RxCompletable
//  RxObjC
// 
//  Created by Pavel Malkov on 30.08.17.
//  Copyright (c) 2014-2017 Pavel Malkov. All rights reserved.
//

#import "RxCompletable.h"
#import "RxObservable+Creation.h"

RxPrimitiveTrait const RxPrimitiveTraitCompletable = @"rx.traits.completable";

@implementation RxCompletable

- (RxPrimitiveTrait)trait {
    return RxPrimitiveTraitCompletable;
}

@end

@implementation RxObservable (AsCompletable)

- (nonnull RxCompletable *)asCompletable {
    return [[RxCompletable alloc] initWithSource:[self asObservable]];
}


@end