//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxStableCompositeDisposable.h"
#import "RxDisposable.h"
#import "RxBinaryDisposable.h"


@implementation RxStableCompositeDisposable

+ (nonnull id <RxDisposable>)createDisposable1:(nonnull id <RxDisposable>)disposable1
                                   disposable2:(nonnull id <RxDisposable>)disposable2 {
    return [[RxBinaryDisposable alloc] initWithFirstDisposable:disposable1 andSecondDisposable:disposable2];
}

@end