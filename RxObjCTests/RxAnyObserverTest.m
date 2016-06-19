//
//  RxAnyObserverTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 19.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RxTest.h"
#import "RxAnyObserver.h"

@interface RxAnyObserverTest : RxTest

@end

@implementation RxAnyObserverTest

- (void)testAnonymousObservable_detachesOnDispose {
    RxAnyObserver<NSNumber *> *observer = nil;
}

@end
