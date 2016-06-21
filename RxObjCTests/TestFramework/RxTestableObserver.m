//
//  RxTestableObserver
//  RxObjC
// 
//  Created by Pavel Malkov on 21.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTestableObserver.h"
#import "RxTestScheduler.h"

@implementation RxTestableObserver {
    RxTestScheduler *__nonnull _testScheduler;
    NSMutableArray<RxRecorded<RxEvent<id> *> *> *__nonnull _events;
}

@synthesize events = _events;

- (nonnull instancetype)initWithTestScheduler:(nonnull RxTestScheduler *)testScheduler {
    self = [super init];
    if (self) {
        _events = [NSMutableArray array];
        _testScheduler = testScheduler;
    }
    return self;
}

- (void)on:(nonnull RxEvent<id> *)event {
    [_events addObject:[[RxRecorded alloc] initWithTime:((NSNumber *) _testScheduler.clock).unsignedIntegerValue
                                                  value:event]];
}

@end