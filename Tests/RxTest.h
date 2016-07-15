//
//  RxTest.h
//  RxObjC
//
//  Created by Pavel Malkov on 19.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RxObjC/RxObjC.h>
#import <RxBlocking/RxBlocking.h>
#import "XCTest+Rx.h"
#import "RxRecorded.h"
#import "RxTestScheduler.h"
#import "RxTestableObservable.h"
#import "RxTestableObserver.h"
#import "RxTestError.h"

@interface RxTest : XCTestCase

- (BOOL)accumulateStatistics;
- (void)sleep:(NSTimeInterval)interval;

@end
