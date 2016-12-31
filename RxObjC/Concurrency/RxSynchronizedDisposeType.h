//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxLock.h"
#import "RxDisposable.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RxSynchronizedDisposeType <RxLock, RxDisposable>

- (void)_synchronized_dispose;

@end

NS_ASSUME_NONNULL_END