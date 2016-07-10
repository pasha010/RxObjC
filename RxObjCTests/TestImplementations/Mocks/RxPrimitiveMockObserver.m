//
//  RxPrimitiveMockObserver
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxPrimitiveMockObserver.h"

@implementation RxPrimitiveMockObserver {
    NSMutableArray<RxRecorded<RxEvent *> *> *__nonnull _events;
}

@synthesize events = _events;

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _events = [NSMutableArray array];
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    [_events addObject:[[RxRecorded alloc] initWithTime:0 value:event]];
}

@end