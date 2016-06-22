//
//  RxSubscription
//  RxObjC
// 
//  Created by Pavel Malkov on 21.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSubscription.h"


@implementation RxSubscription

- (nonnull instancetype)initWithSubsribe:(NSUInteger)subscribe {
    return [self initWithSubscribe:subscribe unsubscribe:NSUIntegerMax];
}


- (nonnull instancetype)initWithSubscribe:(NSUInteger)subscribe unsubscribe:(NSUInteger)unsubscribe {
    self = [super init];
    if (self) {
        _subscribe = subscribe;
        _unsubscribe = unsubscribe;
    }

    return self;
}

- (NSUInteger)hash {
    return _subscribe ^ _unsubscribe;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"(%zd : %@)", _subscribe, _unsubscribe != NSUIntegerMax ? @(_unsubscribe) : @"infinity"];
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (!other || ![[other class] isEqual:[self class]]) {
        return NO;
    }

    RxSubscription *_other = other;

    return self.subscribe == _other.subscribe && self.unsubscribe == _other.unsubscribe;
}


@end