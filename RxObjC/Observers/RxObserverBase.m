//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObserverBase.h"

@implementation RxObserverBase {
    volatile int32_t _isStopped;
}

- (void)on:(nonnull RxEvent<id> *)event {
    if (event.type == RxEventTypeNext) {
        if (_isStopped == 0) {
            [self _onCore:event];
        }
    } else {
        if (!OSAtomicCompareAndSwap32(0, 1, &_isStopped)) {
            return;
        }

        [self _onCore:event];
    }
}

- (void)_onCore:(nonnull RxEvent<id> *)event {
    rx_abstractMethod();
}

- (void)dispose {
    _isStopped = 1;
}


@end