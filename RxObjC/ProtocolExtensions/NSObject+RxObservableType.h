//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservableType.h"
#import "RxObservable.h"

@interface NSObject (RxObservableType) <RxObservableType>

- (nonnull RxObservable<id> *)asObservable;

@end