//
//  RxCocoaCommon
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxCocoaCommon.h"

typedef NS_ENUM(NSUInteger, RxCocoaErrorType) {
    RxCocoaErrorTypeUnknown,
    RxCocoaErrorTypeInvalidOperation,
    RxCocoaErrorTypeItemsNotYetBound,
    RxCocoaErrorTypeInvalidPropertyName,
    RxCocoaErrorTypeInvalidObjectOnKeyPath,
    RxCocoaErrorTypeErrorDuringSwizzling,
    RxCocoaErrorTypeCastingError,
};

@implementation RxCocoaError {
    RxCocoaErrorType _type;
}

+ (nonnull instancetype)unknown {
    static RxCocoaError *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
       instance =  [[RxCocoaError alloc] initWithType:RxCocoaErrorTypeUnknown object:nil propertyName:nil sourceObject:nil targetType:nil];
    });
    return instance;
}

+ (nonnull instancetype)invalidOperation:(nonnull id)object {
    static RxCocoaError *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance =  [[RxCocoaError alloc] initWithType:RxCocoaErrorTypeInvalidOperation object:object propertyName:nil sourceObject:nil targetType:nil];
    });
    return instance;
}

+ (nonnull instancetype)itemsNotYetBound:(nonnull id)object {
    static RxCocoaError *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance =  [[RxCocoaError alloc] initWithType:RxCocoaErrorTypeItemsNotYetBound object:object propertyName:nil sourceObject:nil targetType:nil];
    });
    return instance;
}

+ (nonnull instancetype)invalidPropertyName:(nonnull id)object propertyName:(nonnull NSString *)propertyName {
    static RxCocoaError *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance =  [[RxCocoaError alloc] initWithType:RxCocoaErrorTypeInvalidPropertyName object:object propertyName:propertyName sourceObject:nil targetType:nil];
    });
    return instance;
}

+ (nonnull instancetype)invalidObjectOnKeyPath:(nonnull id)object sourceObject:(nonnull id)sourceObject propertyName:(nonnull NSString *)propertyName {
    static RxCocoaError *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance =  [[RxCocoaError alloc] initWithType:RxCocoaErrorTypeInvalidObjectOnKeyPath object:object propertyName:propertyName sourceObject:sourceObject targetType:nil];
    });
    return instance;
}

+ (nonnull instancetype)errorDuringSwizzling {
    static RxCocoaError *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance =  [[RxCocoaError alloc] initWithType:RxCocoaErrorTypeErrorDuringSwizzling object:nil propertyName:nil sourceObject:nil targetType:nil];
    });
    return instance;
}

+ (nonnull instancetype)castingError:(nonnull id)object targetType:(nonnull id)targetType {
    static RxCocoaError *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance =  [[RxCocoaError alloc] initWithType:RxCocoaErrorTypeCastingError object:object propertyName:nil sourceObject:nil targetType:targetType];
    });
    return instance;
}

- (nonnull instancetype)init {
    return [RxCocoaError unknown];
}

- (nonnull instancetype)initWithType:(RxCocoaErrorType)type object:(nullable id)object propertyName:(nullable id)propertyName sourceObject:(nullable id)sourceObject targetType:(nullable id)targetType {
    self = [super initWithDomain:@"rx.objc" code:_type userInfo:nil];
    if (self) {
        _type = type;
        _object = object;
        _propertyName = propertyName;
        _sourceObject = sourceObject;
        _targetType = targetType;
        
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (!other || ![[other class] isEqual:[self class]]) {
        return NO;
    }

    return [self isEqualToError:other];
}

- (BOOL)isEqualToError:(RxCocoaError *)error {
    if (self == error) {
        return YES;
    }
    if (error == nil) {
        return NO;
    }
    if (_type != error->_type) {
        return NO;
    }
    if (self.object != error.object && ![self.object isEqual:error.object]) {
        return NO;
    }
    if (self.propertyName != error.propertyName && ![self.propertyName isEqual:error.propertyName]) {
        return NO;
    }
    if (self.sourceObject != error.sourceObject && ![self.sourceObject isEqual:error.sourceObject]) {
        return NO;
    }

    if (self.targetType != error.targetType && ![self.targetType isEqual:error.targetType]) {
        return NO;
    }
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = (NSUInteger) _type;
    hash = hash * 31u + [self.object hash];
    hash = hash * 31u + [self.propertyName hash];
    hash = hash * 31u + [self.sourceObject hash];
    hash = hash * 31u + [self.targetType hash];
    return hash;
}

- (NSString *)description {
    switch (_type) {
        case RxCocoaErrorTypeUnknown: {
            return @"Unknown error occurred";
        }
        case RxCocoaErrorTypeInvalidOperation: {
            return [NSString stringWithFormat:@"Invalid operation was attempted on `%@`", _object];
        }
        case RxCocoaErrorTypeItemsNotYetBound: {
            return [NSString stringWithFormat:@"Data source is set, but items are not yet bound to user interface for `%@`", _object];
        }
        case RxCocoaErrorTypeInvalidPropertyName:{
            return [NSString stringWithFormat:@"Object `%@` dosn't have a property named `%@`", _object, _propertyName];
        }
        case RxCocoaErrorTypeInvalidObjectOnKeyPath:{
            return [NSString stringWithFormat:@"Unobservable object `%@` was observed as `%@` of `%@`", _object, _propertyName, _sourceObject];
        }
        case RxCocoaErrorTypeErrorDuringSwizzling:{
            return [NSString stringWithFormat:@"Error during swizzling"];
        }
        case RxCocoaErrorTypeCastingError:{
            return [NSString stringWithFormat:@"Error casting `%@` to `%@`", _object, _targetType];
        }
    }
}

- (NSString *)debugDescription {
    return [self description];
}


@end

#if !DISABLE_SWIZZLING

@implementation RxCocoaObjCRuntimeError {
    NSString *__nonnull _type;
}

+ (instancetype)unknown:(id)target {
    static RxCocoaObjCRuntimeError *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSString *type = [NSString stringWithFormat:@"Unknown error occurred.\nTarget: `%@`", target];
        instance = [[RxCocoaObjCRuntimeError alloc] initWithType:type andTarget:target];
    });
    return instance;
}

+ (instancetype)objectMessagesAlreadyBeingIntercepted:(id)target interceptionMechanism:(RxCocoaInterceptionMechanism)interceptionMechanism {
    static RxCocoaObjCRuntimeError *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSString *interception = interceptionMechanism == RxCocoaInterceptionMechanismKVO ? @"KVO" : @"other interception mechanism";
        NSString *type = [NSString stringWithFormat:@"Collision between RxCocoa interception mechanism and %@"
                          "To resolve this conflict please use this interception mechanism first.\nTarget: (%@)", interception, target];
        instance = [[RxCocoaObjCRuntimeError alloc] initWithType:type andTarget:target];
        instance.interceptionMechanism = interceptionMechanism;
    });
    return instance;
}

+ (instancetype)selectorNotImplemented:(id)target {
    static RxCocoaObjCRuntimeError *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSString *type = [NSString stringWithFormat:@"Trying to observe messages for selector that isn't implemented.\nTarget: %@", target];
        instance =  [[RxCocoaObjCRuntimeError alloc] initWithType:type andTarget:target];
    });
    return instance;
}

+ (instancetype)cantInterceptCoreFoundationTollFreeBridgedObjects:(id)target {
    static RxCocoaObjCRuntimeError *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSString *type = [NSString stringWithFormat:@"Interception of messages sent to Core Foundation isn't supported.\nTarget: %@", target];
        instance = [[RxCocoaObjCRuntimeError alloc] initWithType:type andTarget:target];
    });
    return instance;
}

+ (instancetype)threadingCollisionWithOtherInterceptionMechanism:(id)target {
    static RxCocoaObjCRuntimeError *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSString *type = [NSString stringWithFormat:@"Detected a conflict while modifying ObjC runtime.\nTarget: %@", target];
        instance = [[RxCocoaObjCRuntimeError alloc] initWithType:type andTarget:target];
    });
    return instance;
}

+ (instancetype)savingOriginalForwardingMethodFailed:(id)target {
    static RxCocoaObjCRuntimeError *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSString *type = [NSString stringWithFormat:@"Saving original method implementation failed.\nTarget: %@", target];
        instance = [[RxCocoaObjCRuntimeError alloc] initWithType:type andTarget:target];
    });
    return instance;
}

+ (instancetype)replacingMethodWithForwardingImplementation:(id)target {
    static RxCocoaObjCRuntimeError *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSString *type = [NSString stringWithFormat:@"Intercepting a sent message by replacing a method implementation with `_objc_msgForward` failed for some reason.\nTarget: %@", target];
        instance = [[RxCocoaObjCRuntimeError alloc] initWithType:type andTarget:target];
    });
    return instance;
}

+ (instancetype)observingPerformanceSensitiveMessages:(id)target {
    static RxCocoaObjCRuntimeError *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSString *type = [NSString stringWithFormat:@"Attempt to intercept one of the performance sensitive methods. \nTarget: %@", target];
        instance = [[RxCocoaObjCRuntimeError alloc] initWithType:type andTarget:target];
    });
    return instance;
}

+ (instancetype)observingMessagesWithUnsupportedReturnType:(id)target {
    static RxCocoaObjCRuntimeError *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSString *type = [NSString stringWithFormat:@"Attempt to intercept a method with unsupported return type. \nTarget: %@", target];
        instance = [[RxCocoaObjCRuntimeError alloc] initWithType:type andTarget:target];
    });
    return instance;
}

- (nonnull instancetype)initWithType:(nonnull NSString *)type andTarget:(nonnull id)target {
    self = [super initWithDomain:@"rx.objc" code:_type.hash userInfo:nil];
    if (self) {
        _type = type;
        _target = target;
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (!other || ![[other class] isEqual:[self class]]) {
        return NO;
    }

    return [self isEqualToError:other];
}

- (BOOL)isEqualToError:(RxCocoaObjCRuntimeError *)error {
    if (self == error) {
        return YES;
    }
    if (error == nil) {
        return NO;
    }
    if (_type != error->_type && ![_type isEqualToString:error->_type]) {
        return NO;
    }
    if (self.target != error.target && ![self.target isEqual:error.target]) {
        return NO;
    }
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [_type hash];
    hash = hash * 31u + [self.target hash];
    return hash;
}

- (NSString *)description {
    return _type;
}

- (NSString *)debugDescription {
    return [self description];
}

@end

#endif

#pragma mark - Error binding policies

void rx_bindingErrorToInterface(NSError *__nonnull error) {
    NSString *e = [NSString stringWithFormat:@"Binding error to UI: %@", error];
#if defined(DEBUG) && DEBUG
    rx_fatalError(e);
#else
    NSLog(@"%@", e);
#endif
}

#pragma mark Abstract methods

void rx_abstractMethodWithMessage(NSString *__nonnull message) {
    rx_fatalError(message);
}

#pragma mark - Casts or fatal error

id __nonnull rx_castOrThrow(Class __nonnull castClass, id __nonnull object) {
    if ([object isKindOfClass:[NSNull class]] || [object isKindOfClass:[RxNil class]]) {
        return nil;
    }

    if ([object isKindOfClass:castClass]) {
        return object;
    }
    @throw [RxCocoaError castingError:object targetType:castClass];
}

id __nonnull rx_castOrFatalError(Class __nonnull castClass, id __nonnull object, NSString *__nonnull message) {
    if ([object isKindOfClass:castClass]) {
        return object;
    }
    rx_fatalError(message);
    return nil;
}

#pragma mark - Conversions `NSError` > `RxCocoaObjCRuntimeError`

@implementation NSError (RxCocoaErrorForTarget)

- (nonnull RxCocoaObjCRuntimeError *)rxCocoaErrorForTarget:(nonnull id)target {
    if (self.domain == RxObjCRuntimeErrorDomain) {
        RxObjCRuntimeError errorCode = RxObjCRuntimeErrorUnknown;
        if (self.code >= RxCocoaErrorTypeUnknown && self.code <= RxObjCRuntimeErrorObservingMessagesWithUnsupportedReturnType) {
            errorCode = (RxObjCRuntimeError) self.code;
        }

        switch (errorCode) {
            case RxObjCRuntimeErrorUnknown: {
                return [RxCocoaObjCRuntimeError unknown:target];
            }
            case RxObjCRuntimeErrorObjectMessagesAlreadyBeingIntercepted: {
                BOOL isKVO = NO;
                if ([self.userInfo[RxObjCRuntimeErrorIsKVOKey] isKindOfClass:[NSNumber class]]) {
                    isKVO = [self.userInfo[RxObjCRuntimeErrorIsKVOKey] boolValue];
                }
                return [RxCocoaObjCRuntimeError objectMessagesAlreadyBeingIntercepted:target interceptionMechanism:isKVO ? RxCocoaInterceptionMechanismKVO : RxCocoaInterceptionMechanismUnknown];
            }
            case RxObjCRuntimeErrorSelectorNotImplemented: {
                return [RxCocoaObjCRuntimeError selectorNotImplemented:target];
            };
            case RxObjCRuntimeErrorCantInterceptCoreFoundationTollFreeBridgedObjects: {
                return [RxCocoaObjCRuntimeError cantInterceptCoreFoundationTollFreeBridgedObjects:target];
            };
            case RxObjCRuntimeErrorThreadingCollisionWithOtherInterceptionMechanism: {
                return [RxCocoaObjCRuntimeError threadingCollisionWithOtherInterceptionMechanism:target];
            };
            case RxObjCRuntimeErrorSavingOriginalForwardingMethodFailed: {
                return [RxCocoaObjCRuntimeError savingOriginalForwardingMethodFailed:target];
            };
            case RxObjCRuntimeErrorReplacingMethodWithForwardingImplementation: {
                return [RxCocoaObjCRuntimeError replacingMethodWithForwardingImplementation:target];
            };
            case RxObjCRuntimeErrorObservingPerformanceSensitiveMessages: {
                return [RxCocoaObjCRuntimeError observingPerformanceSensitiveMessages:target];
            };
            case RxObjCRuntimeErrorObservingMessagesWithUnsupportedReturnType: {
                return [RxCocoaObjCRuntimeError observingMessagesWithUnsupportedReturnType:target];
            };
        }
    }
    return [RxCocoaObjCRuntimeError unknown:target];
}


@end