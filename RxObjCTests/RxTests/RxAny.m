//
//  RxAny
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxAny.h"


@implementation RxAny

- (nonnull instancetype)initWithTarget:(nonnull id)target comparer:(RxAnyComparer)comparer {
    self = [super init];
    if (self) {
        _target = target;
        _comparer = [comparer copy];
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
    RxAny *o = other;

    return self.comparer(self.target, o.target);
}

- (NSString *)debugDescription {
    return [self description];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", _target];
}


@end