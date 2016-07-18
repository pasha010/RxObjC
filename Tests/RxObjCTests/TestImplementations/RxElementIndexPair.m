//
//  RxElementIndexPair
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxElementIndexPair.h"


@implementation RxElementIndexPair

- (nonnull instancetype)initWithElement:(id)element index:(NSUInteger)index {
    self = [super init];
    if (self) {
        _element = element;
        _index = index;
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (!other || ![[other class] isEqual:[self class]]) {
        return NO;
    }

    return [self isEqualToPair:other];
}

- (BOOL)isEqualToPair:(nonnull RxElementIndexPair *)pair {
    if (self == pair) {
        return YES;
    }
    if (pair == nil) {
        return NO;
    }
    if (self.element != pair.element) {
        return NO;
    }
    return self.index == pair.index;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.element hash];
    hash = hash * 31u + self.index;
    return hash;
}

@end