//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObserverType.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A type-erased `ObserverType`.
 *
 * Forwards operations to an arbitrary underlying observer with the same `Element` type, hiding the specifics of the underlying observer type.
 */

@interface RxAnyObserver<__covariant Element> : NSObject <RxObserverType>

@property (copy, nonatomic) RxEventHandler observer;

/**
 * Construct an instance whose `on(event)` calls `observer.on(event)`
 * @param observer - Observer that receives sequence events.
 */
- (nonnull instancetype)initWithObserver:(nonnull id <RxObserverType>)observer;

/**
 * Construct an instance whose `on(event)` calls `eventHandler(event)`
 * @param eventHandler - Event handler that observes sequences events.
 */
- (nonnull instancetype)initWithEventHandler:(RxEventHandler)eventHandler NS_DESIGNATED_INITIALIZER;

/**
 * Erases type of observer and returns canonical observer.
 * @return - type erased observer.
 */
- (nonnull RxAnyObserver<Element> *)asObserver;

/**
 * Convenience method equivalent to `on(.Next(element: E))`
 * @param element - Next element to send to observer(s)
 */
- (void)onNext:(nullable id)element;

/**
 * Convenience method equivalent to `on(.Completed)`
 */
- (void)onCompleted;

/**
 * Convenience method equivalent to `on(.Error(error: ErrorType))`
 * @param error - ErrorType to send to observer(s)
*/
- (void)onError:(nullable NSError *)error;

@end

FOUNDATION_EXTERN RxAnyObserver<id> *_Nonnull rx_asObserver(id <RxObserverType> _Nonnull observer);

NS_ASSUME_NONNULL_END