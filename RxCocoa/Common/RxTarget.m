//
//  RxTarget
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTarget.h"


#pragma clang diagnostic push
#pragma ide diagnostic ignored "UnavailableInDeploymentTarget"

@implementation RxTarget {
    __weak RxTarget *__nullable _retainSelf;
}

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _retainSelf = self;
#if TRACE_RESOURCES
        OSAtomicIncrement32(&rx_resourceCount);
#endif
#if DEBUG
        [RxMainScheduler ensureExecutingOnScheduler];
#endif
    }
    return self;
}

- (void)dispose {
    _retainSelf = nil;
}

#if TRACE_RESOURCES
- (void)dealloc {
    OSAtomicDecrement32(&rx_resourceCount);
}
#endif

@end

#pragma clang diagnostic pop