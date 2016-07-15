//
// Created by Pavel Malkov on 21.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxRecorded.h"


@implementation RxRecorded

- (nonnull instancetype)initWithTime:(RxTestTime)time value:(nonnull id)value {
    self = [super init];
    if (self) {
        _time = time;
        _value = value;
    }

    return self;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@ @ %u", _value, _time];
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (!other || ![[other class] isEqual:[self class]]) {
        return NO;
    }

    RxRecorded *_other = other;

    return self.time == _other.time && [self.value isEqual:_other.value];
}


@end