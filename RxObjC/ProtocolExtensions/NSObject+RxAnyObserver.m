//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "NSObject+RxAnyObserver.h"
#import "RxAnyObserver.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation NSObject (RxAnyObserver)

- (nonnull RxAnyObserver<id> *)asObserver {
    return [[RxAnyObserver alloc] initWithObserverEvent:self];
}

@end
#pragma clang diagnostic pop