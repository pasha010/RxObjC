//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxError.h"


@implementation RxError

+ (nonnull instancetype)unknown {
    return [self errorWithDomain:@"rx.objc" code:1001 userInfo:@{NSLocalizedDescriptionKey: @"Unknown error occured"}];
}

+ (nonnull instancetype)disposedObject:(nonnull id)object {
    return [self errorWithDomain:@"rx.objc" code:1002 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Object `%@` was already disposed", object]}];
}

+ (nonnull instancetype)overflow {
    return [self errorWithDomain:@"rx.objc" code:1003 userInfo:@{NSLocalizedDescriptionKey: @"Arithmetic overflow occured"}];
}

+ (nonnull instancetype)argumentOutOfRange {
    return [self errorWithDomain:@"rx.objc" code:1004 userInfo:@{NSLocalizedDescriptionKey: @"Argument out of range"}];
}

+ (nonnull instancetype)noElements {
    return [self errorWithDomain:@"rx.objc" code:1005 userInfo:@{NSLocalizedDescriptionKey: @"Sequence doesn't contain any elements"}];
}

+ (nonnull instancetype)moreThanOneElement {
    return [self errorWithDomain:@"rx.objc" code:1006 userInfo:@{NSLocalizedDescriptionKey: @"Sequence contains more than one element"}];
}

+ (nonnull instancetype)timeout {
    return [self errorWithDomain:@"rx.objc" code:1007 userInfo:@{NSLocalizedDescriptionKey: @"Sequence timeout"}];
}

@end