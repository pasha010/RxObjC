//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxEvent.h"

NS_ASSUME_NONNULL_BEGIN

/**
Supports push-style iteration over an observable sequence.
*/
@protocol RxObserverType <NSObject>
/**
 * Notify observer about sequence event.
 * - parameter event: Event that occured.
*/
- (void)on:(nonnull RxEvent<id> *)event;

@end

NS_ASSUME_NONNULL_END