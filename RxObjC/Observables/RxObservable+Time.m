//
//  RxObservable(Time)
//  RxObjC
// 
//  Created by Pavel Malkov on 04.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable+Time.h"
#import "RxThrottle.h"
#import "RxSample.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation NSObject (RxThrottle)

- (nonnull RxObservable *)throttle:(RxTimeInterval)dueTime scheduler:(nonnull id <RxSchedulerType>)scheduler {
    return [self debounce:dueTime scheduler:scheduler];
}

- (nonnull RxObservable *)debounce:(RxTimeInterval)dueTime scheduler:(nonnull id <RxSchedulerType>)scheduler {
    return [[RxThrottle alloc] initWithSource:[self asObservable] dueTime:dueTime scheduler:scheduler];
}

@end

@implementation NSObject (RxSample)

- (nonnull RxObservable *)sample:(nonnull id <RxObservableType>)sampler {
    return [[RxSample alloc] initWithSource:[self asObservable] sampler:[sampler asObservable] onlyNew:YES];
}

@end

#pragma clang diagnostic pop