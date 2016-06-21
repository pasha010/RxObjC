//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservableType.h"
#import "RxObservable.h"
#import "RxObservable+Creation.h"
#import "RxAnyObserver.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation NSObject (RxObservableType)

- (nonnull RxObservable *)asObservable {
    return [RxObservable create:^id <RxDisposable>(RxAnyObserver *observer) {
        return [self subscribe:observer];
    }];
}

@end
#pragma clang diagnostic pop