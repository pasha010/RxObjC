//
//  RxEquatableArray
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxEquatableArray.h"


@implementation RxEquatableArray {
    NSArray *__nonnull _elements;
}

- (nonnull instancetype)initWithElements:(nonnull NSArray *)elements {
    self = [super init];
    if (self) {
        _elements = elements;
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToArray:other];
}

- (BOOL)isEqualToArray:(RxEquatableArray *)array {
    if (self == array) {
        return YES;
    }
    if (array == nil) {
        return NO;
    }
    if (_elements != array->_elements && ![_elements isEqualToArray:array->_elements]) {
        return NO;
    }
    return YES;
}

- (NSUInteger)hash {
    return [_elements hash];
}

@end