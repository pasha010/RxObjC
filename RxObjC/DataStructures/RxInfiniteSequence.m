//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxInfiniteSequence.h"


@implementation RxInfiniteSequence {
    id __nonnull _repeatedValue;
}

- (nonnull instancetype)initWithRepeatedValue:(nonnull id)repeatedValue {
    self = [super init];
    if (self) {
        _repeatedValue = repeatedValue;
    }
    return self;
}

- (nonnull NSArray<id> *)array {
    return @[_repeatedValue];
}


@end