//
//  _RxObjCRuntime.h
//  RxCocoa
//
//  Created by Pavel Malkov on 18.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

#if !DISABLE_SWIZZLING

/**
 * ################################################################################
 * This file is part of Rx private API
 * ################################################################################
 */

/**
 *  This flag controls `RELEASE` configuration behavior in case race was detecting while modifying
 *  ObjC runtime.
 *
 *  In case this value is set to `YES`, after runtime race is detected, `abort()` will be called.
 *  Otherwise, only error will be reported using normal error reporting mechanism.
 *
 *  In `DEBUG` mode `abort` will be always called in case race is detected.
 *
 *  Races can't happen in case this is the only library modifying ObjC runtime, but in case there are multiple libraries
 *  changing ObjC runtime, race conditions can occur because there is no way to synchronize multiple libraries unaware of
 *  each other.
 *
 *  To help remedy this situation this library will use `synchronized` on target object and it's meta-class, but
 *  there aren't any guarantees of how other libraries will behave.
 *
 *  Default value is `NO`.
 */
extern BOOL RxAbortOnThreadingHazard;

/**
 * Error domain for RxObjCRuntime.
 */
extern NSString * __nonnull const RxObjCRuntimeErrorDomain;

/**
 * `userInfo` key with additional information is interceptor probably KVO.
 */
extern NSString * __nonnull const RxObjCRuntimeErrorIsKVOKey;

typedef NS_ENUM(NSInteger, RxObjCRuntimeError) {
    RxObjCRuntimeErrorUnknown                                           = 1,
    RxObjCRuntimeErrorObjectMessagesAlreadyBeingIntercepted             = 2,
    RxObjCRuntimeErrorSelectorNotImplemented                            = 3,
    RxObjCRuntimeErrorCantInterceptCoreFoundationTollFreeBridgedObjects = 4,
    RxObjCRuntimeErrorThreadingCollisionWithOtherInterceptionMechanism  = 5,
    RxObjCRuntimeErrorSavingOriginalForwardingMethodFailed              = 6,
    RxObjCRuntimeErrorReplacingMethodWithForwardingImplementation       = 7,
    RxObjCRuntimeErrorObservingPerformanceSensitiveMessages             = 8,
    RxObjCRuntimeErrorObservingMessagesWithUnsupportedReturnType        = 9,
};

/**
 * Transforms normal selector into a selector with Rx prefix.
 */
SEL _Nonnull Rx_selector(SEL _Nonnull selector);

/**
 * Transforms selector into a unique pointer (because of Swift conversion rules)
 */
void * __nonnull Rx_reference_from_selector(SEL __nonnull selector);

/**
 * Protocol that interception observers must implement.
 */
@protocol RxMessageSentObserver

/**
 * In case the same selector is being intercepted for a pair of base/sub classes,
 * this property will differentiate between interceptors that need to fire.
 */
@property (nonatomic, readonly) IMP __nonnull targetImplementation;

- (void)messageSentWithParameters:(nonnull NSArray *)parameters;

@end

/**
 * Ensures interceptor is installed on target object.
 */
IMP __nullable Rx_ensure_observing(id __nonnull target, SEL __nonnull selector, NSError *__nullable * __nonnull error);

/**
 * Extracts arguments for `invocation`.
 */
NSArray * __nonnull Rx_extract_arguments(NSInvocation * __nonnull invocation);

/**
 * Returns `YES` in case method has `void` return type.
 */
BOOL Rx_is_method_with_description_void(struct objc_method_description method);

/**
 * Returns `YES` in case methodSignature has `void` return type.
 */
BOOL Rx_is_method_signature_void(NSMethodSignature * __nonnull methodSignature);

/**
 * Default value for `RxInterceptionObserver.targetImplementation`.
 */
IMP __nonnull Rx_default_target_implementation();

#endif