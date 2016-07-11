//
//  RxMainThreadPrimitiveHotObservable
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxMainThreadPrimitiveHotObservable.h"
#import <XCTest/XCTest.h>

@implementation RxMainThreadPrimitiveHotObservable

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    XCTAssertTrue([NSThread currentThread].isMainThread);
    return [super subscribe:observer];
}

@end