//
//  NSObject(Rx)
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RxObjC/RxObjC.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * KVO is a tricky mechanism.
 *
 * When observing child in a ownership hierarchy, usually retaining observing target is wanted behavior.
 * When observing parent in a ownership hierarchy, usually retaining target isn't wanter behavior.
 *
 * KVO with weak references is especially tricky. For it to work, some kind of swizzling is required.
 * That can be done by
 *     * replacing object class dynamically (like KVO does)
 *     * by swizzling `dealloc` method on all instances for a class.
 *     * some third method ...
 *
 * Both approaches can fail in certain scenarios:
 *     * problems arise when swizzlers return original object class (like KVO does when nobody is observing)
 *     * Problems can arise because replacing dealloc method isn't atomic operation (get implementation, set implementation).
 *
 * Second approach is chosen. It can fail in case there are multiple libraries dynamically trying
 * to replace dealloc method. In case that isn't the case, it should be ok.
*/
@interface NSObject (RxKVOObserving)

/**
 * Observes values on `keyPath` starting from `self` with `options` and retains `self` if `retainSelf` is set.
 * `rx_observe` is just a simple and performant wrapper around KVO mechanism.
 *
 *  * it can be used to observe paths starting from `self` or from ancestors in ownership graph (`retainSelf = false`)
 *  * it can be used to observe paths starting from descendants in ownership graph (`retainSelf = true`)
 *  * the paths have to consist only of `strong` properties, otherwise you are risking crashing the system by not unregistering KVO observer before dealloc.
 *
 * If support for weak properties is needed or observing arbitrary or unknown relationships in the
 * ownership tree, `rx_observeWeakly` is the preferred option.
 * @param keyPath: Key path of property names to observe.
 * @param options: KVO mechanism notification options.
 * @param retainSelf: Retains self during observation if set `true`.
 * @return: Observable sequence of objects on `keyPath`.
 */
- (nonnull RxObservable *)rx_observe:(nonnull NSString *)keyPath options:(NSKeyValueObservingOptions)options retainSelf:(BOOL)retainSelf;

- (nonnull RxObservable *)rx_observe:(nonnull NSString *)keyPath options:(NSKeyValueObservingOptions)options;

- (nonnull RxObservable *)rx_observe:(nonnull NSString *)keyPath;

@end

#if !DISABLE_SWIZZLING

@interface NSObject (RxKVOWeakly)

/**
 * Observes values on `keyPath` starting from `self` with `options` and doesn't retain `self`.
 *
 * It can be used in all cases where `rx_observe` can be used and additionally
 *
 * because it won't retain observed target, it can be used to observe arbitrary object graph whose ownership relation is unknown
 * it can be used to observe `weak` properties
 *
 * *Since it needs to intercept object deallocation process it needs to perform swizzling of `dealloc` method on observed object.**

 * @param keyPath: Key path of property names to observe.
 * @param options: KVO mechanism notification options.
 * @return: Observable sequence of objects on `keyPath`.
 */
- (nonnull RxObservable *)rx_observeWeakly:(nonnull NSString *)keyPath options:(NSKeyValueObservingOptions)options;

- (nonnull RxObservable *)rx_observeWeakly:(nonnull NSString *)keyPath;

@end

#endif

@interface NSObject (RxDealloc)
/**
 * Observable sequence of object deallocated events.
 * After object is deallocated one `()` element will be produced and sequence will immediately complete.
 * @return: Observable sequence of object deallocated events.
 */
@property (nonnull, strong, readonly) RxObservable *rx_deallocated;

#if !DISABLE_SWIZZLING

/**
 * Observable sequence of message arguments that completes when object is deallocated.
 * In case an error occurs sequence will fail with `RxCocoaObjCRuntimeError`.
 * In case some argument is `nil`, instance of `NSNull()` will be sent.
 * @return: Observable sequence of object deallocating events.
 */
- (nonnull RxObservable<NSArray<id> *> *)rx_sentMessage:(SEL)selector;

/**
 * Observable sequence of object deallocating events.
 * When `dealloc` message is sent to `self` one `()` element will be produced and after object is deallocated sequence
 * will immediately complete.
 * In case an error occurs sequence will fail with `RxCocoaObjCRuntimeError`.
 * @return: Observable sequence of object deallocating events.
 */
@property (nonnull, strong, readonly) RxObservable *rx_deallocating;

#endif

/**
 * Helper to make sure that `Observable` returned from `createCachedObservable` is only created once.
 * This is important because there is only one `target` and `action` properties on `NSControl` or `UIBarButtonItem`.
 */
- (nonnull id)rx_lazyInstanceObservable:(const char *)key createCachedObservable:(nonnull id __nonnull(^)())createCachedObservable;

@end

NS_ASSUME_NONNULL_END