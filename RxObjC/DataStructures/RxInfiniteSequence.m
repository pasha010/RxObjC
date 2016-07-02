//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxInfiniteSequence.h"


@implementation RxInfiniteSequence {
    id __nonnull _repeatedValue;
    NSArray *__nonnull _allObjects;
}

- (nonnull instancetype)initWithRepeatedValue:(nonnull id)repeatedValue {
    self = [super init];
    if (self) {
        _repeatedValue = repeatedValue;
        _allObjects = @[_repeatedValue];

    }
    return self;
}

- (id)nextObject {
    return _repeatedValue;
}

- (NSArray *)allObjects {
    return _allObjects;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained[])buffer count:(NSUInteger)len {
    return 1;
}


@end