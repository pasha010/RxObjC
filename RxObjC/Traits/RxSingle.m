//
//  RxSingle
//  RxObjC
// 
//  Created by Pavel Malkov on 30.08.17.
//  Copyright (c) 2014-2017 Pavel Malkov. All rights reserved.
//

#import "RxSingle.h"
#import "RxSingleAsync.h"
#import "RxAnyObserver.h"
#import "RxObservable+Creation.h"
#import "RxObjCCommon.h"

RxPrimitiveTrait const RxPrimitiveTraitSingle = @"rx.traits.single";

@implementation RxSingle

- (RxPrimitiveTrait)trait {
    return RxPrimitiveTraitSingle;
}

@end

@implementation RxSingle (Creation)

+ (nonnull instancetype)create:(id <RxDisposable>(^ _Nonnull)(RxSingleObserver))subscribe {
    RxObservable *o = [RxObservable create:^id <RxDisposable>(RxAnyObserver *observer) {
        return subscribe(^(RxSingleEvent *event) {
            if (event.isSuccess) {
                [observer onNext:((RxSingleEventSuccess *) event).element];
                [observer onCompleted];
            } else {
                [observer onError:((RxSingleEventError *) event).error];
            }
        });
    }];
    return [[RxSingle alloc] initWithSource:o];
}

- (nonnull id <RxDisposable>)subscribe:(void (^ _Nonnull)(RxSingleEvent *))observer {
    __block BOOL stopped = NO;
    return [[self asObservable] subscribeWith:^(RxEvent *event) {
        if (stopped) {
            return;
        }
        stopped = YES;

        switch (event.type) {
            case RxEventTypeNext:
                observer([RxSingleEventSuccess create:event.element]);
                break;
            case RxEventTypeError:
                observer([RxSingleEventError create:event.error]);
                break;
            case RxEventTypeCompleted:
                rx_fatalError(@"Singles can't emit a completion event");
                break;
        }
    }];
}

- (nonnull id <RxDisposable>)subscribeOnSuccess:(void(^_Nullable)(id))success
                                        onError:(void(^_Nullable)(NSError *))error {
    return [self subscribe:^(RxSingleEvent *event) {
        if (event.isSuccess) {
            if (success) {
                success(((RxSingleEventSuccess *) event).element);
            }
        } else {
            if (error) {
                error(((RxSingleEventError *) event).error);
            }
        }
    }];
}

- (nonnull id <RxDisposable>)subscribeOnSuccess:(void(^_Nullable)(id))success {
    return [self subscribeOnSuccess:success onError:nil];
}

@end

@implementation RxObservable (AsSingle)

- (nonnull RxSingle<id> *)asSingle {
    return [[RxSingle alloc] initWithSource:[self asObservable]];
}

- (nonnull RxSingle<id> *)first {
    return [[RxSingle alloc] initWithSource:[[RxSingleAsync alloc] initWithSource:[self asObservable]]];
}

@end

@implementation RxSingleEvent

@dynamic isSuccess;
@dynamic isError;

- (BOOL)isSuccess {
    return [self isKindOfClass:[RxSingleEventSuccess class]];
}

- (BOOL)isError {
    return [self isKindOfClass:[RxSingleEventError class]];
}

@end

@implementation RxSingleEventSuccess

+ (instancetype)create:(id)element {
    return [[RxSingleEventSuccess alloc] initWithElement:element];
}

- (instancetype)initWithElement:(id)element {
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

- (BOOL)isEqualToSuccess:(RxSingleEventSuccess *)success {
    if (self == success)
        return YES;
    if (success == nil)
        return NO;
    if (self.element != success.element && ![self.element isEqual:success.element]) {
        return NO;
    }
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

@implementation RxSingleEventError

+ (instancetype)create:(NSError *)error {
    return [[RxSingleEventError alloc] initWithError:error];
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

- (BOOL)isEqualToError:(RxSingleEventError *)error {
    if (self == error)
        return YES;
    if (error == nil)
        return NO;
    if (self.error != error.error && ![self.error isEqual:error.error]) {
        return NO;
    }
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