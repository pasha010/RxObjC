//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservableType.h"
#import "RxObservableType.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation NSObject (RxObservableType)

- (nonnull RxObservable *)asObservable {
    return nil;
    // TODO return [RxObservable create:[self subscribe:nil]]
}

@end
#pragma clang diagnostic pop