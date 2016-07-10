//
//  RxMockDisposable
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxMockDisposable.h"
#import "RxTestScheduler.h"

@implementation RxMockDisposable {
    NSMutableArray<NSNumber *> *_ticks;
    RxTestScheduler *__nonnull _scheduler;
}

@synthesize ticks = _ticks;

- (nonnull instancetype)initWithScheduler:(nonnull RxTestScheduler *)scheduler {
    self = [super init];
    if (self) {
        _ticks = [NSMutableArray array];
        _scheduler = scheduler;
        [_ticks addObject:[_scheduler clock]];
    }
    return self;
}

- (void)dispose {
    [_ticks addObject:[_scheduler clock]];
}

@end