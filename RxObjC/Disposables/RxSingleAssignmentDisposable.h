//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxDisposeBase.h"
#import "RxDisposable.h"
#import "RxCancelable.h"
#import "RxLock.h"

NS_ASSUME_NONNULL_BEGIN

/**
Represents a disposable resource which only allows a single assignment of its underlying disposable resource.

If an underlying disposable resource has already been set, future attempts to set the underlying disposable resource will throw an exception.
*/
@interface RxSingleAssignmentDisposable : RxDisposeBase <RxDisposable, RxCancelable> {
@package
    RxSpinLock *__nonnull _lock;
}

/**
Gets or sets the underlying disposable. After disposal, the result of getting this property is undefined.

**Throws exception if the `SingleAssignmentDisposable` has already been assigned to.**
*/
@property (nonnull, strong) id <RxDisposable> disposable;

/**
Initializes a new instance of the `SingleAssignmentDisposable`.
*/
- (nonnull instancetype)init;

- (BOOL)disposed;

- (void)dispose;

@end

NS_ASSUME_NONNULL_END