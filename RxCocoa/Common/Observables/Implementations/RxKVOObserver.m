//
//  RxKVOObserver
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxKVOObserver.h"


@implementation RxKVOObserver

- (nonnull instancetype)initWithParent:(nonnull id <RxKVOObservableProtocol>)parent callback:(nonnull RxKVOCallback)callback {
    self = [super initWithTarget:parent.target retainTarget:parent.retainTarget keyPath:parent.keyPath options:parent.options callback:callback];
    if (self) {
#if TRACE_RESOURCES
        OSAtomicIncrement32(&rx_resourceCount);
#endif
        self.retainSelf = self;
    }
    return self;
}

- (void)dispose {
    [super dispose];
    self.retainSelf = nil;
}

#if TRACE_RESOURCES
- (void)dealloc {
    OSAtomicDecrement32(&rx_resourceCount);
}
#endif

@end