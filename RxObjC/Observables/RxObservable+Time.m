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
#import "RxTimer.h"
#import "RxTake.h"
#import "RxSkip.h"
#import "RxObservable+StandardSequenceOperators.h"
#import "RxDelaySubscription.h"
#import "RxBufferTimeCount.h"


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

@implementation RxObservable (Interval)

- (nonnull RxObservable<NSNumber *> *)interval:(RxTimeInterval)period
                                     scheduler:(nonnull id <RxSchedulerType>)scheduler {
    return [[RxTimer alloc] initWithDueTime:period period:period scheduler:scheduler];
}

@end

@implementation RxObservable (Timer)

- (nonnull RxObservable<NSNumber *> *)timer:(RxTimeInterval)dueTime
                                     period:(RxTimeInterval)period
                                  scheduler:(nonnull id <RxSchedulerType>)scheduler {
    return [[RxTimer alloc] initWithDueTime:dueTime period:period scheduler:scheduler];
}

- (nonnull RxObservable<NSNumber *> *)timer:(RxTimeInterval)dueTime
                                  scheduler:(nonnull id <RxSchedulerType>)scheduler {
    return [self timer:dueTime period:-1 scheduler:scheduler];
}

@end

@implementation NSObject (RxTake)

- (nonnull RxObservable *)take:(RxTimeInterval)duration scheduler:(nonnull id <RxSchedulerType>)scheduler {
    return [[RxTakeTime alloc] initWithSource:[self asObservable] duration:duration scheduler:scheduler];
}

@end

@implementation NSObject (RxSkip)

- (nonnull RxObservable *)skip:(RxTimeInterval)duration scheduler:(nonnull id <RxSchedulerType>)scheduler {
    return [[RxSkipTime alloc] initWithSource:[self asObservable] duration:duration scheduler:scheduler];
}

@end

@implementation NSObject (RxIgnoreElements)

- (nonnull RxObservable *)ignoreElements {
    return [self filter:^BOOL(id o) {
        return NO;
    }];
}

@end

@implementation NSObject (RxDelaySubscription)

- (nonnull RxObservable *)delaySubscription:(RxTimeInterval)dueTime scheduler:(nonnull id <RxSchedulerType>)scheduler {
    return [[RxDelaySubscription alloc] initWithSource:[self asObservable] dueTime:dueTime scheduler:scheduler];
}

@end

@implementation NSObject (RxBuffer)

- (nonnull RxObservable<NSArray<id> *> *)buffer:(RxTimeInterval)timeSpan count:(NSUInteger)count scheduler:(nonnull id <RxSchedulerType>)scheduler {
    return [[RxBufferTimeCount alloc] initWithSource:[self asObservable] timeSpan:timeSpan count:count scheduler:scheduler];
}

@end

#pragma clang diagnostic pop