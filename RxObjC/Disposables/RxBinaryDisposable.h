//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxDisposeBase.h"
#import "RxCancelable.h"

@protocol RxDisposable;

NS_ASSUME_NONNULL_BEGIN

/**
Represents two disposable resources that are disposed together.
*/
@interface RxBinaryDisposable : RxDisposeBase <RxCancelable>

/**
Constructs new binary disposable from two disposables.

- parameter disposable1: First disposable
- parameter disposable2: Second disposable
*/
- (nonnull instancetype)initWithFirstDisposable:(nullable id <RxDisposable>)disposable1 andSecondDisposable:(nullable id <RxDisposable>)disposable2;
@end

NS_ASSUME_NONNULL_END