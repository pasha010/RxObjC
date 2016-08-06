//
//  RxCocoaCommon
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RxObjC/RxObjC.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 * RxCocoa errors
 */
@interface RxCocoaError : NSError

@property (nullable, nonatomic, strong) id object;

@property (nullable, nonatomic, strong) id propertyName;

@property (nullable, nonatomic, strong) id sourceObject;

@property (nullable, nonatomic, strong) id targetType;

/**
 * Unknown error has occurred.
 */
+ (nonnull instancetype)unknown;

/**
 * Invalid operation was attempted.
 */
+ (nonnull instancetype)invalidOperation:(nonnull id)object;

/**
 * Items are not yet bound to user interface but have been requested.
 */
+ (nonnull instancetype)itemsNotYetBound:(nonnull id)object;

/**
 * Invalid KVO Path.
 */
+ (nonnull instancetype)invalidPropertyName:(nonnull id)object propertyName:(nonnull NSString *)propertyName;

+ (nonnull instancetype)invalidObjectOnKeyPath:(nonnull id)object sourceObject:(nonnull id)sourceObject propertyName:(nonnull NSString *)propertyName;

/**
 * Error during swizzling.
 */
+ (nonnull instancetype)errorDuringSwizzling;

/**
 * Casting error.
 */
+ (nonnull instancetype)castingError:(nonnull id)object targetType:(nonnull id)targetType;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToError:(RxCocoaError *)error;

@end

#if !DISABLE_SWIZZLING

/**
 * RxCocoa ObjC runtime interception mechanism.
 */
typedef NS_ENUM(NSUInteger, RxCocoaInterceptionMechanism) {
    /* Unknown message interception mechanism. */
    RxCocoaInterceptionMechanismUnknown,
    /* Key value observing interception mechanism. */
    RxCocoaInterceptionMechanismKVO
};

/**
 * RxCocoa ObjC runtime modification errors.
 */
@interface RxCocoaObjCRuntimeError : NSError

@property (nonnull, nonatomic, strong) id target;
@property (nonatomic) RxCocoaInterceptionMechanism interceptionMechanism;

/**
 * Unknown error has occurred.
 */
+ (nonnull instancetype)unknown:(nonnull id)target;

/**
 * If the object is reporting a different class then it's real class, that means that there is probably
 * already some interception mechanism in place or something weird is happening.
 * The most common case when this would happen is when using a combination of KVO (`rx_observe`) and `rx_sentMessage`.
 * This error is easily resolved by just using `rx_sentMessage` observing before `rx_observe`.
 * The reason why the other way around could create issues is because KVO will unregister it's interceptor
 * class and restore original class. Unfortunately that will happen no matter was there another interceptor
 * subclass registered in hierarchy or not.
 *
 * Failure scenario:
 * * KVO sets class to be `__KVO__OriginalClass` (subclass of `OriginalClass`)
 * * `rx_sentMessage` sets object class to be `_RX_namespace___KVO__OriginalClass` (subclass of `__KVO__OriginalClass`)
 * * then unobserving with KVO will restore class to be `OriginalClass` -> failure point (possibly a bug in KVO)
 *
 * The reason why changing order of observing works is because any interception method on unregistration
 * should return object's original real class (if that doesn't happen then it's really easy to argue that's a bug
 * in that interception mechanism).
 *
 * This library won't remove registered interceptor even if there aren't any observers left because
 * it's highly unlikely it would have any benefit in real world use cases, and it's even more
 * dangerous.
 */
+ (nonnull instancetype)objectMessagesAlreadyBeingIntercepted:(nonnull id)target interceptionMechanism:(RxCocoaInterceptionMechanism)interceptionMechanism;

/**
 * Trying to observe messages for selector that isn't implemented.
 */
+ (nonnull instancetype)selectorNotImplemented:(nonnull id)target;

/**
 * Core Foundation classes are usually toll free bridged. Those classes crash the program in case
 * `object_setClass` is performed on them.
 *
 * There is a possibility to just swizzle methods on original object, but since those won't be usual use
 * cases for this library, then an error will just be reported for now.
 */
+ (nonnull instancetype)cantInterceptCoreFoundationTollFreeBridgedObjects:(nonnull id)target;

/**
 * Two libraries have simultaneously tried to modify ObjC runtime and that was detected. This can only
 * happen in scenarios where multiple interception libraries are used.
 *
 * To synchronize other libraries intercepting messages for an object, use `synchronized` on target object and
 * it's meta-class.
 */
+ (nonnull instancetype)threadingCollisionWithOtherInterceptionMechanism:(nonnull id)target;

/**
 * For some reason saving original method implementation under RX namespace failed.
 */
+ (nonnull instancetype)savingOriginalForwardingMethodFailed:(nonnull id)target;

/**
 * Intercepting a sent message by replacing a method implementation with `_objc_msgForward` failed for some reason.
 */
+ (nonnull instancetype)replacingMethodWithForwardingImplementation:(nonnull id)target;

/**
 * Attempt to intercept one of the performance sensitive methods:
 * * class
 * * respondsToSelector:
 * * methodSignatureForSelector:
 * * forwardingTargetForSelector:
 */
+ (nonnull instancetype)observingPerformanceSensitiveMessages:(nonnull id)target;

/**
 * Message implementation has unsupported return type (for example large struct). The reason why this is a error
 * is because in some cases intercepting sent messages requires replacing implementation with `_objc_msgForward_stret`
 * instead of `_objc_msgForward`.
 *
 * The unsupported cases should be fairly uncommon.
 */
+ (nonnull instancetype)observingMessagesWithUnsupportedReturnType:(nonnull id)target;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToError:(RxCocoaObjCRuntimeError *)error;

@end

#endif

#pragma mark - Error binding policies

void rx_bindingErrorToInterface(NSError *__nonnull error);

#pragma mark - Abstract methods

void rx_abstractMethodWithMessage(NSString *__nonnull message);

#pragma mark - Casts or fatal error

id __nonnull rx_castOrThrow(Class __nonnull castClass, id __nonnull object);

id __nonnull rx_castOrFatalError(Class __nonnull castClass, id __nonnull object, NSString *__nonnull message);

#pragma mark - Error messages

static NSString *const rx_dataSourceNotSet = @"DataSource not set";
static NSString *const rx_delegateNotSet = @"Delegate not set";

#if !DISABLE_SWIZZLING

#pragma mark - Conversions `NSError` > `RxCocoaObjCRuntimeError`

@interface NSError (RxCocoaErrorForTarget)

- (nonnull RxCocoaObjCRuntimeError *)rxCocoaErrorForTarget:(nonnull id)target;

@end

#endif

NS_ASSUME_NONNULL_END