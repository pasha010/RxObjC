//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxDisposeBase.h"
#import "RxCancelable.h"

NS_ASSUME_NONNULL_BEGIN

/**
    Represents a disposable resource that only disposes its underlying disposable resource when all dependent disposable objects have been disposed.
 */
@interface RxRefCountDisposable : RxDisposeBase <RxCancelable>

/**
 Initializes a new instance of the `RefCountDisposable`.
 */
- (nonnull instancetype)initWithDisposable:(nonnull id <RxDisposable>)disposable;

/**
 Holds a dependent disposable that when disposed decreases the refcount on the underlying disposable.

 When getter is called, a dependent disposable contributing to the reference count that manages the underlying disposable's lifetime is returned.
 */
- (nonnull id <RxDisposable>)rx_retain;

@end

NS_ASSUME_NONNULL_END