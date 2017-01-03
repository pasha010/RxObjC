//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxDisposeBase.h"
#import "RxDisposable.h"

NS_ASSUME_NONNULL_BEGIN

/**
Thread safe bag that disposes added disposables on `deinit`.

This returns ARC (RAII) like resource management to `RxSwift`.

In case contained disposables need to be disposed, just put a different dispose bag
or create a new one in its place.

    self.existingDisposeBag = DisposeBag()

In case explicit disposal is necessary, there is also `CompositeDisposable`.
*/
@interface RxDisposeBag : RxDisposeBase

/**
Adds `disposable` to be disposed when dispose bag is being deinited.

- parameter disposable: Disposable to add.
*/
- (void)addDisposable:(nonnull id <RxDisposable>)disposable;

@end

NS_ASSUME_NONNULL_END