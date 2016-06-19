//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "NSObject+RxObservableType.h"
#import "RxObservable.h"

@implementation NSObject (RxObservableType)

- (nonnull RxObservable<id> *)asObservable {
    return nil;
    // TODO return [RxObservable create:[self subscribe:nil]]
}

@end