//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTestScheduler.h"
#import "RxTestSchedulerVirtualTimeConverter.h"


@implementation RxTestScheduler {
    BOOL _simulateProcessingDelay;
}

- (nonnull instancetype)initWithInitialClock:(NSUInteger)initialClock
                                  resolution:(double)resolution
                     simulateProcessingDelay:(BOOL)simulateProcessingDelay {
    // complete test scheduler
    self = [super initWithInitialClock:@(initialClock) andConverter:[[RxTestSchedulerVirtualTimeConverter alloc] initWithResolution:resolution]];
    if (self) {
        _simulateProcessingDelay = simulateProcessingDelay;
    }
    return self;
}

@end