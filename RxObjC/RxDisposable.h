//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Respresents a disposable resource.
 */
@protocol RxDisposable <NSObject>
/**
 * Dispose resource.
 */
- (void)dispose;

@end

NS_ASSUME_NONNULL_END