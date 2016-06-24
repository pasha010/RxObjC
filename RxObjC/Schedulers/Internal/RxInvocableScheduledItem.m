//
//  RxInvocableScheduledItem
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxInvocableScheduledItem.h"


@implementation RxInvocableScheduledItem {
    id <RxInvocableWithValueType> __nonnull _invocable;
    id _state;
}

- (nonnull instancetype)initWithInvocable:(nonnull id <RxInvocableWithValueType>)invocable state:(nonnull id)state {
    self = [super init];
    if (self) {
        _invocable = invocable;
        _state = state;
    }
    return self;
}

- (void)invoke {
    [_invocable invoke:_state];
}


@end