//
//  RxNever
//  RxObjC
// 
//  Created by Pavel Malkov on 25.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxNever.h"
#import "RxNopDisposable.h"


@implementation RxNever

- (nonnull instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    return [[RxNopDisposable alloc] init];
}


@end