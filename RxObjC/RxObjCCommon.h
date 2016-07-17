//
//  RxObjCCommon.h
//  RxObjCCommon
//
//  Created by Pavel Malkov on 18.06.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import "RxObjCExt.h"
#import <libkern/OSAtomic.h>

#define TRACE_RESOURCES 1

FOUNDATION_EXTERN int32_t rx_resourceCount;

FOUNDATION_EXTERN id rx_abstractMethod();
FOUNDATION_EXTERN void rx_fatalError(NSString *message);
FOUNDATION_EXTERN NSInteger rx_incrementChecked(NSInteger *i);
FOUNDATION_EXTERN NSInteger rx_decrementChecked(NSInteger *i);
FOUNDATION_EXTERN NSUInteger rx_incrementCheckedUnsigned(NSUInteger *i);
FOUNDATION_EXTERN NSUInteger rx_decrementCheckedUnsigned(NSUInteger *i);

FOUNDATION_EXTERN void rx_tryCatch(void (^tryBlock)(), void (^catchBlock)(NSError *));

/**
Counts number of `SerialDispatchQueueObservables`.

Purposed for unit tests.
*/
#if TRACE_RESOURCES
FOUNDATION_EXTERN int32_t rx_numberOfSerialDispatchQueueObservables;
FOUNDATION_EXTERN int32_t rx_numberOfMapOperators;
#endif

#if DEBUG || (defined(TRACE_RESOURCES) && TRACE_RESOURCES)
FOUNDATION_EXTERN NSUInteger rx_maxTailRecursiveSinkStackSize;
#endif