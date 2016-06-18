//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxAnonymousObserver.h"

@implementation RxAnonymousObserver {
    RxEventHandler _eventHandler;
}

- (nonnull instancetype)initWithEventHandler:(nonnull RxEventHandler)eventHandler {
    self = [super init];
    if (self) {
#if TRACE_RESOURCES
        OSAtomicIncrement32(&rx_resourceCount);
#endif
        _eventHandler = eventHandler;
    }
    return self;
}

- (void)_onCore:(nonnull RxEvent *)event {
    _eventHandler(event);
}

#if TRACE_RESOURCES
- (void)dealloc {
    OSAtomicDecrement32(&rx_resourceCount);
}
#endif


@end