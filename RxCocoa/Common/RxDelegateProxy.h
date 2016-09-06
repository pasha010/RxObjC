//
//  RxDelegateProxy
//  RxObjC
// 
//  Created by Pavel Malkov on 05.09.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxCocoa.h"
#import <RxObjC/RxObjC.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN uint8_t rx_delegateAssociatedTag;
FOUNDATION_EXTERN uint8_t rx_dataSourceAssociatedTag;

/**
 * Base class for `DelegateProxyType` protocol.
 * This implementation is not thread safe and can be used only from one thread (Main thread).
*/
@interface RxDelegateProxy : _RxDelegateProxy

/**
 * Initializes new instance.
 * @param parentObject: Optional parent object that owns `DelegateProxy` as associated object.
 */
- (nonnull instancetype)initWithParentObject:(nonnull id)parentObject;

/**
 * Returns observable sequence of invocations of delegate methods.
 * Only methods that have `void` return value can be observed using this method because
 * those methods are used as a notification mechanism. It doesn't matter if they are optional
 * or not. Observing is performed by installing a hidden associated `PublishSubject` that is
 * used to dispatch messages to observers.
 *
 * Delegate methods that have non `void` return value can't be observed directly using this method
 * because:
 * * those methods are not intended to be used as a notification mechanism, but as a behavior customization mechanism
 * * there is no sensible automatic way to determine a default return value
 *
 * In case observing of delegate methods that have return type is required, it can be done by
 * manually installing a `PublishSubject` or `BehaviorSubject` and implementing delegate method.
 *
 * In case calling this method prints "Delegate proxy is already implementing `\(selector)`,
 * a more performant way of registering might exist.", that means that manual observing method
 * is required analog to the example above because delegate method has already been implemented.**
 *
 * @param selector: Selector used to filter observed invocations of delegate methods.
 * @return: Observable sequence of arguments passed to `selector` method.
 */
- (nonnull RxObservable<NSArray *> *)observe:(nonnull SEL)selector;

/**
 * Returns tag used to identify associated object.
 * @return: Associated object tag.
 */
+ (const void *)delegateAssociatedObjectTag;

/**
 * Initializes new instance of delegate proxy.
 * @return: Initialized instance of `self`.
 */
+ (nonnull instancetype)createProxyForObject:(nonnull id)object;

/**
 * Returns assigned proxy for object.
 * @param object: Object that can have assigned delegate proxy.
 * @return: Assigned delegate proxy or `nil` if no delegate proxy is assigned.
 */
+ (nullable id)assignedProxyFor:(nonnull id)object;

/**
 Assigns proxy to object.
 * @param proxy: Delegate proxy object to assign to `object`.
 * @param object: Object that can have assigned delegate proxy.
 */
+ (void)assignProxy:(nonnull id)proxy toObject:(nonnull id)object;

/**
 * Sets reference of normal delegate that receives all forwarded messages
 * through `self`.
 * @param forwardToDelegate: Reference of delegate that receives all messages through `self`.
 * @param retainDelegate: Should `self` retain `forwardToDelegate`.
 */
- (void)setForwardToDelegate:(nullable id)delegate retainDelegate:(BOOL)retainDelegate;

/**
 * Returns reference of normal delegate that receives all forwarded messages
 * through `self`.
 * @return: Value of reference if set or nil.
 */
- (nullable id)forwardToDelegate;

@end

NS_ASSUME_NONNULL_END