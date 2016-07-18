//
//  RxObjCCommon.m
//  RxObjCCommon
//
//  Created by Pavel Malkov on 18.06.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import "RxObjCCommon.h"
#import "RxError.h"

int32_t rx_resourceCount = 0;

id rx_abstractMethod() {
    rx_fatalError(@"Abstract method");
    return nil;
}

void rx_fatalError(NSString *message) {
    assert(NO && [message cStringUsingEncoding:NSUTF8StringEncoding]);
}

NSInteger rx_incrementChecked(NSInteger *i) {
    if (*i == NSIntegerMax) {
        @throw [RxError overflow];
    }
    NSInteger result = *i;
    *i = *i + 1;
    return result;
}

NSInteger rx_decrementChecked(NSInteger *i) {
    if (*i == NSIntegerMin) {
        @throw [RxError overflow];
    }
    NSInteger result = *i;
    *i = *i - 1;
    return result;
}

NSUInteger rx_incrementCheckedUnsigned(NSUInteger *i) {
    if (*i == NSUIntegerMax) {
        @throw [RxError overflow];
    }
    NSUInteger result = *i;
    *i = *i + 1;
    return result;
}

NSUInteger rx_decrementCheckedUnsigned(NSUInteger *i) {
    if (*i == 0) {
        @throw [RxError overflow];
    }
    NSUInteger result = *i;
    *i = *i - 1;
    return result;
}

void rx_tryCatch(void (^tryBlock)(), void (^catchBlock)(NSError *)) {
    @try {
        tryBlock();
    }
    @catch (id e) {
        NSError *error = e;
        if ([e isKindOfClass:[NSException class]]) {
            NSException *exception = e;
            error = [NSError errorWithDomain:exception.name
                                        code:[exception.name hash]
                                    userInfo:exception.userInfo];
        }
        catchBlock(error);
    }
}

#if TRACE_RESOURCES
int32_t rx_numberOfSerialDispatchQueueObservables = 0;
int32_t rx_numberOfMapOperators = 0;
#endif

#if DEBUG || (defined(TRACE_RESOURCES) && TRACE_RESOURCES)
NSUInteger rx_maxTailRecursiveSinkStackSize = 0;
#endif