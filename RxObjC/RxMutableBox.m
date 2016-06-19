//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxMutableBox.h"


@implementation RxMutableBox

- (nonnull instancetype)initWithValue:(nonnull id)value {
    self = [super init];
    if (self) {
        _value = value;
    }
    return self;
}

/**
- returns: Box description.
*/
- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"MutatingBox(%@)", self.value];
}


@end