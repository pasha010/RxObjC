//
//  RxObservable(StandardSequenceOperators)
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable+StandardSequenceOperators.h"
#import "RxObservable.h"
#import "RxMap.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation NSObject (RxMap)

- (nonnull RxObservable *)map:(RxMapSelector)mapSelector {
    return [[self asObservable] _composeMap:mapSelector];
}

- (nonnull RxObservable *)mapWithIndex:(RxMapWithIndexSelector)mapSelector {
    return [[RxMapWithIndex alloc] initWithSource:[self asObservable] selector:mapSelector];
}

@end

@implementation NSObject (RxFlatMap)
@end


#pragma clang diagnostic pop