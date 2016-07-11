//
//  RxObjCCommon.h
//  RxObjCCommon
//
//  Created by Pavel Malkov on 18.06.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import "RxObjCExt.h"

#define TRACE_RESOURCES 1

FOUNDATION_EXTERN int32_t rx_resourceCount;

FOUNDATION_EXTERN id rx_abstractMethod();
FOUNDATION_EXTERN void rx_fatalError(NSString *message);
FOUNDATION_EXTERN NSInteger rx_incrementChecked(NSInteger *i);
FOUNDATION_EXTERN NSInteger rx_decrementChecked(NSInteger *i);
FOUNDATION_EXTERN NSUInteger rx_incrementCheckedUnsigned(NSUInteger *i);
FOUNDATION_EXTERN NSUInteger rx_decrementCheckedUnsigned(NSUInteger *i);