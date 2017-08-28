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
    int64_t bytes;
    int64_t allocations;
};

typedef struct RxMemoryInfo RxMemoryInfo;

@interface RxPerformanceTools : NSObject

@property (class, atomic, nonnull, strong, readonly) RxPerformanceTools *defaultTools;

@property (atomic, assign, readonly) RxMemoryInfo memoryInfo;

- (void)registerMallocHooks;

@end



NS_ASSUME_NONNULL_END