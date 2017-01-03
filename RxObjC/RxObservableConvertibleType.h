//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RxObservable<E>;

NS_ASSUME_NONNULL_BEGIN

/**
 * Type that can be converted to observable sequence (`Observer<E>`).
 */
@protocol RxObservableConvertibleType <NSObject>
- (nonnull RxObservable<id> *)asObservable;
@end

NS_ASSUME_NONNULL_END