//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxDisposeBase.h"
#import "RxDisposable.h"
#import "RxCancelable.h"

@class RxBagKey;

NS_ASSUME_NONNULL_BEGIN

/**
Represents a group of disposable resources that are disposed together.
*/
@interface RxCompositeDisposable : RxDisposeBase <RxDisposable, RxCancelable>

- (nonnull instancetype)init;

/**
 Initializes a new instance of composite disposable with the specified number of disposables.
*/
- (nonnull instancetype)initWithDisposable1:(nonnull id <RxDisposable>)disposable1
                                disposable2:(nonnull id <RxDisposable>)disposable2;

/**
 Initializes a new instance of composite disposable with the specified number of disposables.
*/
- (nonnull instancetype)initWithDisposable1:(nonnull id <RxDisposable>)disposable1
                                disposable2:(nonnull id <RxDisposable>)disposable2
                                disposable3:(nonnull id <RxDisposable>)disposable3;

/**
 Initializes a new instance of composite disposable with the specified number of disposables.
 */
- (nonnull instancetype)initWithDisposable1:(nonnull id <RxDisposable>)disposable1
                                disposable2:(nonnull id <RxDisposable>)disposable2
                                disposable3:(nonnull id <RxDisposable>)disposable3
                                disposable4:(nonnull id <RxDisposable>)disposable4;

/**
 Initializes a new instance of composite disposable with the specified number of disposables.
*/
- (nonnull instancetype)initWithDisposableArray:(nonnull NSArray<id <RxDisposable>> *)disposables NS_DESIGNATED_INITIALIZER;

/**
Adds a disposable to the CompositeDisposable or disposes the disposable if the CompositeDisposable is disposed.

- parameter disposable: Disposable to add.
- returns: Key that can be used to remove disposable from composite disposable. In case dispose bag was already
    disposed `nil` will be returned.
*/
- (nullable RxBagKey *)addDisposable:(nonnull id <RxDisposable>)disposable;

/**
- returns: Gets the number of disposables contained in the `CompositeDisposable`.
*/
- (NSUInteger)count;

/**
Removes and disposes the disposable identified by `disposeKey` from the CompositeDisposable.

- parameter disposeKey: Key used to identify disposable to be removed.
*/
- (void)removeDisposable:(nonnull RxBagKey *)disposable;
@end

NS_ASSUME_NONNULL_END