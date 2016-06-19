//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxSynchronizedDisposeType.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (RxSynchronizedDisposeType) <RxSynchronizedDisposeType>

- (void)synchronizedDispose;

@end

NS_ASSUME_NONNULL_END