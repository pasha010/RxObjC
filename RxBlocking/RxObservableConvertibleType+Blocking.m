//
//  RxObservableConvertibleType(Blocking)
//  RxObjC
// 
//  Created by Pavel Malkov on 13.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservableConvertibleType+Blocking.h"
#import "RxBlockingObservable.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma GCC diagnostic ignored "-Wprotocol"

@implementation NSObject (RxBlocking)

- (nonnull RxBlockingObservable *)toBlocking {
    return [[RxBlockingObservable alloc] initWithSource:[self asObservable]];
}

@end

#pragma clang diagnostic pop