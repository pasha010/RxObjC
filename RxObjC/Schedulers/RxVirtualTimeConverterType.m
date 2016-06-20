//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxVirtualTimeConverterType.h"


@implementation RxVirtualTimeComparison

+ (nonnull instancetype)lessThan {
    static dispatch_once_t token;
    static RxVirtualTimeComparison *lessThanInstance;
    dispatch_once(&token, ^{
        lessThanInstance = [[RxVirtualTimeComparison alloc] initWithType:RxVirtualTimeComparisonTypeLessThan];
    });
    return lessThanInstance;
}

+ (nonnull instancetype)equal {
    static dispatch_once_t token;
    static RxVirtualTimeComparison *equalInstance;
    dispatch_once(&token, ^{
        equalInstance = [[RxVirtualTimeComparison alloc] initWithType:RxVirtualTimeComparisonTypeEqual];
    });
    return equalInstance;
}

+ (nonnull instancetype)greaterThan {
    static dispatch_once_t token;
    static RxVirtualTimeComparison *greaterThanInstance;
    dispatch_once(&token, ^{
        greaterThanInstance = [[RxVirtualTimeComparison alloc] initWithType:RxVirtualTimeComparisonTypeGreaterThan];
    });
    return greaterThanInstance;
}

- (nonnull instancetype)initWithType:(RxVirtualTimeComparisonType)type {
    self = [super init];
    if (self) {
        _type = type;
        _lessThan = _type == RxVirtualTimeComparisonTypeLessThan;
        _equal = _type == RxVirtualTimeComparisonTypeEqual;
        _greaterThan = _type == RxVirtualTimeComparisonTypeGreaterThan;
    }
    return self;
}

@end