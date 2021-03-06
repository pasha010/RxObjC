//
//  RxBackgroundThreadPrimitiveHotObservable
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxBackgroundThreadPrimitiveHotObservable.h"
#import "RxObjC.h"

@implementation RxBackgroundThreadPrimitiveHotObservable

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    NSAssert([NSThread currentThread].isMainThread == NO, @"its background thread, not main");
    return [super subscribe:observer];
}

@end