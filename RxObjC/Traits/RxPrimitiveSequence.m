//
//  RxPrimitiveSequence
//  RxObjC
// 
//  Created by Pavel Malkov on 30.08.17.
//  Copyright (c) 2014-2017 Pavel Malkov. All rights reserved.
//

#import <RxObjC/RxObjC.h>
#import "RxPrimitiveSequence.h"
#import "RxObservable.h"
#import "RxObservable+Creation.h"
#import "RxObservable+Time.h"
#import "RxObservable+Single.h"

@implementation RxPrimitiveSequence

@dynamic trait;

- (instancetype)initWithSource:(RxObservable *)source {
    self = [super init];
    if (self) {
        _source = source;
    }
    return self;
}

- (nonnull RxObservable<id> *)asObservable {
    return _source;
}

@end

@implementation RxPrimitiveSequence (Extension)

+ (nonnull instancetype)deferred:(RxPrimitiveSequence<id> *(^ _Nonnull)(void))observableFactory {
    return [[self alloc] initWithSource:[RxObservable deferred:^RxObservable * {
        return [observableFactory() asObservable];
    }]];
}

+ (nonnull instancetype)just:(id)element {
    return [[self alloc] initWithSource:[RxObservable just:element]];
}

+ (nonnull instancetype)just:(id)element scheduler:(nonnull id <RxImmediateSchedulerType>)scheduler {
    return [[self alloc] initWithSource:[RxObservable just:element scheduler:scheduler]];
}

+ (nonnull instancetype)error:(NSError *)error {
    return [[self alloc] initWithSource:[RxObservable error:error]];
}

+ (nonnull instancetype)never {
    return [[self alloc] initWithSource:[RxObservable never]];
}

- (nonnull instancetype)delaySubscription:(RxTimeInterval)dueTime scheduler:(nonnull id <RxSchedulerType>)scheduler {
    return [(RxPrimitiveSequence *) [[self class] alloc] initWithSource:[self.source delaySubscription:dueTime scheduler:scheduler]];
}

- (nonnull instancetype)doOnNext:(void (^ _Nullable)(id value))onNext {
    return [(RxPrimitiveSequence *) [[self class] alloc] initWithSource:[self.source doOnNext:onNext]];
}

- (nonnull instancetype)doOnError:(void (^ _Nullable)(NSError *))onError {
    return [(RxPrimitiveSequence *) [[self class] alloc] initWithSource:[self.source doOnError:onError]];
}

- (nonnull instancetype)doOnCompleted:(void (^ _Nullable)())onCompleted {
    return [(RxPrimitiveSequence *) [[self class] alloc] initWithSource:[self.source doOnCompleted:onCompleted]];
}

- (nonnull instancetype)doOnNext:(void (^ _Nullable)(id value))onNext onError:(void (^ _Nullable)(NSError *))onError onCompleted:(void (^ _Nullable)())onCompleted {
    return [(RxPrimitiveSequence *) [[self class] alloc] initWithSource:[self.source doOnNext:onNext onError:onError onCompleted:onCompleted]];
}

- (nonnull RxMaybe *)filter:(BOOL(^ _Nonnull)(id _Nonnull element))predicate {
    return [[RxMaybe alloc] initWithSource:[self.source filter:predicate]];
}

- (nonnull __kindof RxPrimitiveSequence<id> *)map:(id(^ _Nonnull)(id _Nonnull))transform {
    return [(RxPrimitiveSequence *) [[self class] alloc] initWithSource:[self.source map:transform]];
}

- (nonnull __kindof RxPrimitiveSequence<id> *)flatMap:(__kindof RxPrimitiveSequence<id> *(^ _Nonnull)(id _Nonnull element))block {
    return [(RxPrimitiveSequence *) [[self class] alloc] initWithSource:[self.source flatMap:block]];
}

- (nonnull instancetype)observeOn:(nonnull RxImmediateScheduler *)scheduler {
    return [(RxPrimitiveSequence *) [[self class] alloc] initWithSource:[self.source observeOn:scheduler]];
}

- (nonnull instancetype)observeOnMainThread {
    return [self observeOn:RxMainScheduler.instance];
}

- (nonnull instancetype)subscribeOn:(nonnull id <RxImmediateSchedulerType>)scheduler {
    return [(RxPrimitiveSequence *) [[self class] alloc] initWithSource:[self.source subscribeOn:scheduler]];
}

- (nonnull instancetype)catchError:(__kindof RxPrimitiveSequence<id> *(^ _Nonnull)(NSError *_Nonnull))handler {
    return [(RxPrimitiveSequence *) [[self class] alloc] initWithSource:[self.source catchError:^RxObservable *(NSError *error) {
        return [handler(error) asObservable];
    }]];
}

- (nonnull instancetype)retry:(NSUInteger)maxAttemptCount {
    return [(RxPrimitiveSequence *) [[self class] alloc] initWithSource:[self.source retry:maxAttemptCount]];
}

- (nonnull instancetype)retryWhen:(id <RxObservableType>(^ _Nonnull)(RxObservable<__kindof NSError *> *_Nonnull))notificationHandler {
    return [(RxPrimitiveSequence *) [[self class] alloc] initWithSource:[self.source retryWhen:notificationHandler]];
}

- (nonnull instancetype)retryWhen:(id <RxObservableType>(^ _Nonnull)(RxObservable<__kindof NSError *> *_Nonnull))notificationHandler
                 customErrorClass:(nullable Class)errorClass {
    return [(RxPrimitiveSequence *) [[self class] alloc] initWithSource:[self.source retryWhen:notificationHandler customErrorClass:errorClass]];
}

- (nonnull instancetype)debug:(nullable NSString *)identifier {
    return [(RxPrimitiveSequence *) [[self class] alloc] initWithSource:[self.source debug:identifier]];
}

- (nonnull instancetype)timeout:(RxTimeInterval)dueTime scheduler:(nonnull id <RxSchedulerType>)scheduler {
    return [(RxPrimitiveSequence *) [[self class] alloc] initWithSource:[self.source timeout:dueTime scheduler:scheduler]];
}

- (nonnull instancetype)timeout:(RxTimeInterval)dueTime
                          other:(nonnull id <RxObservableConvertibleType>)other
                      scheduler:(nonnull id <RxSchedulerType>)scheduler {
    return [(RxPrimitiveSequence *) [[self class] alloc] initWithSource:[self.source timeout:dueTime other:other scheduler:scheduler]];
}

+ (nonnull instancetype)timer:(RxTimeInterval)dueTime scheduler:(nonnull id <RxSchedulerType>)scheduler {
    return [[self alloc] initWithSource:[RxObservable timer:dueTime scheduler:scheduler]];
}

+ (nonnull RxPrimitiveSequence<RxTuple *> *)zip:(nonnull NSArray<__kindof RxPrimitiveSequence<id> *> *)sources {
    NSMutableArray<RxObservable *> *convertedArray = [NSMutableArray array];
    [sources enumerateObjectsUsingBlock:^(RxCompletable *obj, NSUInteger idx, BOOL *stop) {
        [convertedArray addObject:[obj asObservable]];
    }];
    return [[self alloc] initWithSource:[RxObservable zip:convertedArray resultSelector:^id(RxTuple *tuple) {
        return tuple;
    }]];
}

@end