//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxEvent.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Supports push-style iteration over an observable sequence.
 */
@protocol RxObserverType <NSObject>
/**
 * Notify observer about sequence event.
 * - parameter event: Event that occured.
*/
- (void)on:(nonnull RxEvent<id> *)event;

@end

/**
 * Convenience method equivalent to `on(.Next(element: E))`
 * @param element - Next element to send to observer(s)
 */
FOUNDATION_EXTERN void rx_onNext(id <RxObserverType> _Nonnull observer, id _Nullable element);

/**
 * Convenience method equivalent to `on(.Completed)`
 */
FOUNDATION_EXTERN void rx_onCompleted(id <RxObserverType> _Nonnull observer);

/**
 * Convenience method equivalent to `on(.Error(error: ErrorType))`
 * @param error - Error to send to observer(s)
*/
FOUNDATION_EXTERN void rx_onError(id <RxObserverType> _Nonnull observer, NSError *_Nullable error);


NS_ASSUME_NONNULL_END