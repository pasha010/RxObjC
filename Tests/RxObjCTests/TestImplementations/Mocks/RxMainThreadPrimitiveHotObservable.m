//
//  RxMainThreadPrimitiveHotObservable
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxMainThreadPrimitiveHotObservable.h"
#import "RxObjC.h"

@implementation RxMainThreadPrimitiveHotObservable

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    NSAssert([NSThread currentThread].isMainThread, @"it's not background thread, it's main");
    return [super subscribe:observer];
}

@end