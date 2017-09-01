//
//  RxMaybe
//  RxObjC
// 
//  Created by Pavel Malkov on 30.08.17.
//  Copyright (c) 2014-2017 Pavel Malkov. All rights reserved.
//

#import "RxMaybe.h"
#import "RxObservable+Creation.h"
#import "RxAsMaybe.h"
#import "RxAnyObserver.h"

@implementation RxMaybe
@end

@implementation RxMaybe (Creation)

+ (nonnull instancetype)create:(id <RxDisposable>(^ _Nonnull)(RxMaybeObserver))subscribe {
    __auto_type source = [RxObservable create:^id <RxDisposable>(RxAnyObserver *observer) {
        return subscribe(^(RxMaybeEvent *_Nonnull event) {
            if (event.isSuccess) {
                [observer onNext:((RxMaybeEventSuccess *) event).element];
                [observer onCompleted];
            } else if (event.isError) {
                [observer onError:((RxMaybeEventError *) event).error];
            } else {
                [observer onCompleted];
            }
        });
    }];
    return [[RxMaybe alloc] initWithSource:source];
}

- (nonnull id <RxDisposable>)subscribe:(void (^ _Nonnull)(RxMaybeEvent *))observer {
    __block BOOL stopped = NO;
    return [[self asObservable] subscribeWith:^(RxEvent *event) {
        if (stopped) {
            return;
        }
        stopped = YES;

        switch (event.type) {
            case RxEventTypeNext:
                observer([RxMaybeEventSuccess success:event.element]);
                break;
            case RxEventTypeError:
                observer([RxMaybeEventError error:event.error]);
                break;
            case RxEventTypeCompleted:
                observer([RxMaybeEventCompleted completed]);
                break;
        }
    }];
}

- (nonnull id <RxDisposable>)subscribeOnSuccess:(void (^ _Nullable)(id))onSuccess
                                        onError:(void (^ _Nullable)(NSError *))onError
                                    onCompleted:(void (^ _Nullable)())onCompleted {
    return [self subscribe:^(RxMaybeEvent *event) {
        if (event.isSuccess) {
            if (onSuccess) {
                onSuccess(((RxMaybeEventSuccess *) event).element);
            }
        } else if (event.isError) {
            if (onError) {
                onError(((RxMaybeEventError *) event).error);
            }
        } else {
            if (onCompleted) {
                onCompleted();
            }
        }
    }];
}

- (nonnull id <RxDisposable>)subscribeOnSuccess:(void (^ _Nullable)(id))onSuccess {
    return [self subscribeOnSuccess:onSuccess onError:nil];
}

- (nonnull id <RxDisposable>)subscribeOnSuccess:(void (^ _Nullable)(id))onSuccess onError:(void (^ _Nullable)(NSError *))onError {
    return [self subscribeOnSuccess:onSuccess onError:onError onCompleted:nil];
}

@end

@implementation RxMaybe (Extension)

+ (instancetype)empty {
    return [[RxMaybe alloc] initWithSource:[RxObservable empty]];
}

@end

@implementation RxObservable (AsMaybe)

- (nonnull RxMaybe<id> *)asMaybe {
    return [[RxMaybe alloc] initWithSource:[[RxAsMaybe alloc] initWithSource:[self asObservable]]];
}

@end

@implementation RxMaybeEvent

@dynamic isSuccess;
@dynamic isError;
@dynamic isCompleted;

- (BOOL)isSuccess {
    return [self isKindOfClass:[RxMaybeEventSuccess class]];
}

- (BOOL)isError {
    return [self isKindOfClass:[RxMaybeEventError class]];
}

- (BOOL)isCompleted {
    return [self isKindOfClass:[RxMaybeEventCompleted class]];
}

@end

@implementation RxMaybeEventSuccess

+ (instancetype)success:(nullable id)element {
    return [[RxMaybeEventSuccess alloc] initWithElement:element];
}

- (instancetype)initWithElement:(nullable id)element {
    self = [super init];
    if (self) {
        _element = element;
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

    return [self isEqualToSuccess:other];
}

- (BOOL)isEqualToSuccess:(RxMaybeEventSuccess *)success {
    if (self == success)
        return YES;
    if (success == nil)
        return NO;
    if (self.element != success.element && ![self.element isEqual:success.element])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    return [self.element hash];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.element=%@", self.element];
    [description appendString:@">"];
    return description;
}

@end

@implementation RxMaybeEventError

+ (instancetype)error:(NSError *)error {
    return [[RxMaybeEventError alloc] initWithError:error];
}

- (instancetype)initWithError:(NSError *)error {
    self = [super init];
    if (self) {
        _error = error;
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

- (BOOL)isEqualToError:(RxMaybeEventError *)error {
    if (self == error)
        return YES;
    if (error == nil)
        return NO;
    if (self.error != error.error && ![self.error isEqual:error.error])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    return [self.error hash];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.error=%@", self.error];
    [description appendString:@">"];
    return description;
}

@end

@implementation RxMaybeEventCompleted

+ (instancetype)completed {
    static dispatch_once_t token;
    static RxMaybeEventCompleted *instance = nil;
    dispatch_once(&token, ^{
        instance = [[RxMaybeEventCompleted alloc] init];
    });
    return instance;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (!other || ![[other class] isEqual:[self class]]) {
        return NO;
    }

    return [self isEqualToCompleted:other];
}

- (BOOL)isEqualToCompleted:(RxMaybeEventCompleted *)completed {
    if (self == completed)
        return YES;
    if (completed == nil)
        return NO;
    return YES;
}

- (NSUInteger)hash {
    return [self.description hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@>", NSStringFromClass([self class])];
}

@end