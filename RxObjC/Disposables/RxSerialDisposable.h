//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxDisposeBase.h"
#import "RxCancelable.h"

NS_ASSUME_NONNULL_BEGIN

/**
Represents a disposable resource whose underlying disposable resource can be replaced by another disposable resource, causing automatic disposal of the previous underlying disposable resource.
*/
@interface RxSerialDisposable : RxDisposeBase <RxCancelable>

/**
Gets or sets the underlying disposable.

Assigning this property disposes the previous disposable object.

If the `SerialDisposable` has already been disposed, assignment to this property causes immediate disposal of the given disposable object.
*/
@property (nullable, strong) id <RxDisposable> disposable;

/**
Initializes a new instance of the `SerialDisposable`.
*/
- (nonnull instancetype)init;

@end

NS_ASSUME_NONNULL_END