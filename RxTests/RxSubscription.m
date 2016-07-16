//
//  RxSubscription
//  RxObjC
// 
//  Created by Pavel Malkov on 21.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSubscription.h"


@implementation RxSubscription

RxSubscription *Subscription(NSUInteger subscribe, NSUInteger unsubscribe) {
    return [RxSubscription createWithSubscribe:subscribe unsubscribe:unsubscribe];
}

+ (nonnull instancetype)createWithSubscribe:(NSUInteger)subscribe unsubscribe:(NSUInteger)unsubscribe {
    return [[self alloc] initWithSubscribe:subscribe unsubscribe:unsubscribe];
}

- (nonnull instancetype)initWithSubscribe:(NSUInteger)subscribe {
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

- (NSString *)description {
    return [self debugDescription];
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