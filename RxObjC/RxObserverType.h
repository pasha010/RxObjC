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

/**
Convenience method equivalent to `on(.Next(element: E))`

- parameter element: Next element to send to observer(s)
*/
- (void)onNext:(nullable id)element;

/**
Convenience method equivalent to `on(.Completed)`
*/
- (void)onCompleted;

/**
Convenience method equivalent to `on(.Error(error: ErrorType))`
- parameter error: ErrorType to send to observer(s)
*/
- (void)onError:(nullable NSError *)error;
@end

NS_ASSUME_NONNULL_END