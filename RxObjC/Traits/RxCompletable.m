//
//  RxCompletable
//  RxObjC
// 
//  Created by Pavel Malkov on 30.08.17.
//  Copyright (c) 2014-2017 Pavel Malkov. All rights reserved.
//

#import "RxCompletable.h"
#import "RxObservable+Creation.h"
#import "RxAnyObserver.h"
#import "RxObjCCommon.h"
#import "RxObservable+Multiple.h"
#import "RxSingle.h"
#import "RxProducer.h"
#import "RxSink.h"
#import "RxSerialDisposable.h"
#import "RxMaybe.h"

@implementation RxCompletable
@end

@interface RxCompletableObserver : NSObject <RxCompletableObserver>

@property (nullable, nonatomic, copy) void (^onCompleteBlock)();
@property (nullable, nonatomic, copy) void (^onError)(NSError *);

- (instancetype)initWithOnComplete:(void (^)())onComplete onError:(void (^)(NSError *))onError;

@end

@implementation RxCompletableObserver

- (instancetype)initWithOnComplete:(void (^)())onComplete onError:(void (^)(NSError *))onError {
    self = [super init];
    if (self) {
        _onCompleteBlock = [onComplete copy];
        _onError = [onError copy];
    }
    return self;
}

- (void)onComplete {
    if (_onCompleteBlock) {
        _onCompleteBlock();
    }
}

- (void)onError:(NSError *)error {
    if (_onError) {
        _onError(error);
    }
}

@end

@interface RxCompletableEvent : NSObject

@property (readonly) BOOL isCompleted;
@property (readonly) BOOL isError;

@end

@interface RxCompletableEventError : RxCompletableEvent

@property (nullable, strong, readonly) NSError *error;

+ (nonnull instancetype)error:(NSError *)error;

@end

@interface RxCompletableEventCompleted : RxCompletableEvent

+ (nonnull instancetype)completed;

@end

@implementation RxCompletable (Creation)

+ (nonnull instancetype)create:(id <RxDisposable>(^ _Nonnull)(id <RxCompletableObserver>))subscribe {
    return [[RxCompletable alloc] initWithSource:[RxObservable create:^id <RxDisposable>(RxAnyObserver *observer) {
        RxCompletableObserver *completableObserver = [[RxCompletableObserver alloc] initWithOnComplete:^{
            [observer onCompleted];
        } onError:^(NSError *error) {
            [observer onError:error];
        }];
        return subscribe(completableObserver);
    }]];
}

- (nonnull id <RxDisposable>)subscribe:(void (^ _Nonnull)(RxCompletableEvent *_Nonnull))observer {
    __block BOOL stopped = NO;
    return [[self asObservable] subscribeWith:^(RxEvent *event) {
        if (stopped) {
            return;
        }
        stopped = YES;

        switch (event.type) {
            case RxEventTypeNext:
                rx_fatalError(@"Completables can't emit values");
                break;
            case RxEventTypeError:
                observer([RxCompletableEventError error:event.error]);
                break;
            case RxEventTypeCompleted:
                observer([RxCompletableEventCompleted completed]);
                break;
        }
    }];
}

- (nonnull id <RxDisposable>)subscribeOnCompleted:(void (^ _Nullable)())onCompleted onError:(void (^ _Nullable)(NSError *))onError {
    return [self subscribe:^(RxCompletableEvent *event) {
        if (event.isError) {
            if (onError) {
                onError(((RxCompletableEventError *) event).error);
            }
        } else {
            if (onCompleted) {
                onCompleted();
            }
        }
    }];
}

- (nonnull id <RxDisposable>)subscribeOnCompleted:(void (^ _Nullable)())onCompleted {
    return [self subscribeOnCompleted:onCompleted onError:nil];
}

@end

@implementation RxCompletable (Extension)

+ (nonnull instancetype)empty {
    return [[RxCompletable alloc] initWithSource:[RxObservable empty]];
}

+ (nonnull instancetype)concat:(nonnull NSArray<RxCompletable *> *)completables {
    NSMutableArray<RxObservable *> *convertedArray = [NSMutableArray array];
    [completables enumerateObjectsUsingBlock:^(RxCompletable *obj, NSUInteger idx, BOOL *stop) {
        [convertedArray addObject:[obj asObservable]];
    }];
    return [[RxCompletable alloc] initWithSource:[convertedArray concat]];
}

- (nonnull instancetype)concatWith:(nonnull RxCompletable *)completable {
    return [RxCompletable concat:@[self, completable]];
}

+ (nonnull instancetype)merge:(nonnull NSArray<RxCompletable *> *)completables {
    NSMutableArray<RxObservable *> *convertedArray = [NSMutableArray array];
    [completables enumerateObjectsUsingBlock:^(RxCompletable *obj, NSUInteger idx, BOOL *stop) {
        [convertedArray addObject:[obj asObservable]];
    }];
    return [[RxCompletable alloc] initWithSource:[[RxObservable of:convertedArray] merge]];
}

@end

@interface RxConcatCompletable<Element> : RxProducer<Element>

@property (nonnull, nonatomic, strong, readonly) RxObservable *completable;
@property (nonnull, nonatomic, strong, readonly) RxObservable<Element> *second;

- (nonnull instancetype)initWithCompletable:(nonnull RxObservable *)completable
                                     second:(nonnull RxObservable<Element> *)second;

@end

@implementation RxCompletable (AndThen)

- (nonnull RxSingle<id> *)andThenSingle:(RxSingle<id> *)second {
    return [[RxSingle alloc] initWithSource:[[RxConcatCompletable alloc] initWithCompletable:[self asObservable]
                                                                                      second:[second asObservable]]];
}

- (nonnull RxMaybe<id> *)andThenMaybe:(RxMaybe<id> *)second {
    return [[RxMaybe alloc] initWithSource:[[RxConcatCompletable alloc] initWithCompletable:[self asObservable]
                                                                                     second:[second asObservable]]];
}

- (nonnull RxCompletable *)andThenCompletable:(RxCompletable *)second {
    return [[RxCompletable alloc] initWithSource:[[RxConcatCompletable alloc] initWithCompletable:[self asObservable]
                                                                                           second:[second asObservable]]];
}

- (nonnull RxObservable<id> *)andThenObservable:(RxObservable<id> *)second {
    return [[RxConcatCompletable alloc] initWithCompletable:[self asObservable]
                                                     second:[second asObservable]];
}


@end

@implementation RxObservable (AsCompletable)

- (nonnull RxCompletable *)asCompletable {
    return [[RxCompletable alloc] initWithSource:[self asObservable]];
}

@end

@implementation RxCompletableEvent

@dynamic isError;
@dynamic isCompleted;

- (BOOL)isError {
    return [self isKindOfClass:[RxCompletableEventError class]];
}

- (BOOL)isCompleted {
    return [self isKindOfClass:[RxCompletableEventCompleted class]];
}

@end

@implementation RxCompletableEventError

+ (instancetype)error:(NSError *)error {
    return [[RxCompletableEventError alloc] initWithError:error];
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

- (BOOL)isEqualToError:(RxCompletableEventError *)error {
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

@implementation RxCompletableEventCompleted

+ (instancetype)completed {
    static dispatch_once_t token;
    static RxCompletableEventCompleted *instance = nil;
    dispatch_once(&token, ^{
        instance = [[RxCompletableEventCompleted alloc] init];
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

- (BOOL)isEqualToCompleted:(RxCompletableEventCompleted *)completed {
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

@interface RxConcatCompletableSink<O : id <RxObserverType>> : RxSink<O> <RxObserverType>

@property (nonnull, nonatomic, strong, readonly) RxConcatCompletable *parent;
@property (nonnull, nonatomic, strong, readonly) RxSerialDisposable *subscription;

@end

@interface RxConcatCompletableSinkOther<O : id <RxObserverType>> : NSObject <RxObserverType>

@property (nonnull, nonatomic, strong, readonly) RxConcatCompletableSink *parent;

- (instancetype)initWithParent:(RxConcatCompletableSink *)parent;

@end

@implementation RxConcatCompletableSink

- (nonnull instancetype)initWithParent:(nonnull RxConcatCompletable *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
        _subscription = [[RxSerialDisposable alloc] init];
    }
    return self;
}

- (nonnull id <RxDisposable>)run {
    __auto_type sub = [[RxSingleAssignmentDisposable alloc] init];
    _subscription.disposable = sub;
    sub.disposable = [_parent.completable subscribe:self];
    return _subscription;
}

- (void)on:(nonnull RxEvent<id> *)event {
    switch (event.type) {
        case RxEventTypeNext:
            break;
        case RxEventTypeError: {
            [self forwardOn:event];
            [self dispose];
            break;
        }
        case RxEventTypeCompleted: {
            __auto_type otherSink = [[RxConcatCompletableSinkOther alloc] initWithParent:self];
            _subscription.disposable = [_parent.second subscribe:otherSink];
            break;
        }
    }
}

@end

@implementation RxConcatCompletable

- (nonnull instancetype)initWithCompletable:(nonnull RxObservable *)completable second:(nonnull RxObservable *)second {
    self = [super init];
    if (self) {
        _completable = completable;
        _second = second;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxConcatCompletableSink *sink = [[RxConcatCompletableSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end

@implementation RxConcatCompletableSinkOther

- (instancetype)initWithParent:(RxConcatCompletableSink *)parent {
    self = [super init];
    if (self) {
        _parent = parent;
    }
    return self;
}

- (void)on:(nonnull RxEvent<id> *)event {
    [_parent forwardOn:event];
    if (event.isStopEvent) {
        [_parent dispose];
    }
}

@end