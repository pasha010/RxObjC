//
//  RxHistoricalScheduler
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxHistoricalScheduler.h"


@implementation RxHistoricalScheduler

- (nonnull instancetype)init {
    return [self initWithInitialClock:[NSDate dateWithTimeIntervalSince1970:0]];
}

- (nonnull instancetype)initWithInitialClock:(RxTime *)initialClock {
    self = [super initWithInitialClock:initialClock andConverter:[[RxHistoricalSchedulerTimeConverter alloc] init]];
    return self;
}

@end