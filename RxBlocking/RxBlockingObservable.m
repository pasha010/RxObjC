//
//  RxBlockingObservable
//  RxObjC
// 
//  Created by Pavel Malkov on 13.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxBlockingObservable.h"

@implementation RxBlockingObservable

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source {
    self = [super init];
    if (self) {
        _source = source;
    }
    return self;
}

@end