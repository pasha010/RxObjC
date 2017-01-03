//
//  RxObservableConvertibleType(Blocking)
//  RxObjC
// 
//  Created by Pavel Malkov on 13.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservableConvertibleType+Blocking.h"
#import "RxBlockingObservable.h"

@implementation RxObservable (Blocking)

- (nonnull RxBlockingObservable *)toBlocking {
    return [[RxBlockingObservable alloc] initWithSource:[self asObservable]];
}

@end