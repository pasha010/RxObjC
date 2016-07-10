//
//  RxPerformanceTools
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

struct RxMemoryInfo {
    int64_t bytesAllocated;
    int64_t allocCalls;
};

typedef struct RxMemoryInfo RxMemoryInfo;

FOUNDATION_EXPORT RxMemoryInfo rx_getMemoryInfo();

FOUNDATION_EXPORT void rx_registerMallocHooks();



NS_ASSUME_NONNULL_END