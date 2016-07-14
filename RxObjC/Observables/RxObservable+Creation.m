//
//  RxObservable(Creation)
//  RxObjC
// 
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable+Creation.h"
#import "RxAnyObserver.h"
#import "RxAnonymousObservable.h"
#import "RxErrorProducer.h"
#import "RxImmediateSchedulerType.h"
#import "RxSequence.h"
#import "RxEmpty.h"
#import "RxJust.h"
#import "RxNever.h"
#import "RxDeferred.h"
#import "RxCurrentThreadScheduler.h"
#import "RxGenerate.h"
#import "RxRepeatElement.h"
#import "RxUsing.h"
#import "RxRange.h"


@implementation RxObservable (Create)

+ (nonnull RxObservable *)create:(RxAnonymousSubscribeHandler)subscribe {
    return [[RxAnonymousObservable alloc] initWithSubscribeHandler:subscribe];
}

@end

@implementation RxObservable (Empty)

+ (nonnull RxObservable *)empty {
    return [[RxEmpty alloc] init];
}

@end

@implementation RxObservable (Never)

+ (nonnull RxObservable *)never {
    return [[RxNever alloc] init];
}

@end

@implementation RxObservable (Just)

+ (nonnull RxObservable<id> *)just:(nonnull id)element {
    return [[RxJust alloc] initWithElement:element];
}

+ (nonnull RxObservable<id> *)just:(nonnull id)element scheduler:(nonnull id <RxImmediateSchedulerType>)scheduler {
    return [[RxJustScheduled alloc] initWithElement:element scheduler:scheduler];
}

@end

@implementation RxObservable (Fail)

+ (nonnull RxObservable *)error:(nonnull NSError *)error {
    return [RxErrorProducer error:error];
}

@end

@implementation RxObservable (Of)

+ (nonnull RxObservable *)of:(nonnull NSArray *)elements {
    return [self of:elements scheduler:nil];
}

+ (nonnull RxObservable *)of:(nonnull NSArray *)elements scheduler:(nullable id <RxImmediateSchedulerType>)scheduler {
    return [[RxSequence alloc] initWithElements:[elements objectEnumerator] scheduler:scheduler];
}

@end

@implementation RxObservable (Defer)

+ (nonnull RxObservable *)deferred:(RxObservableFactory)observableFactory {
    return [[RxDeferred alloc] initWithObservableFactory:observableFactory];
}

+ (nonnull RxObservable *)generate:(nonnull id)initialState
                         condition:(BOOL(^)(id))condition
                         scheduler:(id <RxImmediateSchedulerType>)scheduler
                           iterate:(id(^)(id))iterate {
    return [[RxGenerate alloc] initWithInitialState:initialState
                                          condition:condition
                                            iterate:iterate
                                     resultSelector:^id(id o) {return o;}
                                          scheduler:scheduler];
}

+ (nonnull RxObservable *)generate:(nonnull id)initialState
                         condition:(BOOL(^)(id))condition
                           iterate:(id(^)(id))iterate {
    return [self generate:initialState condition:condition scheduler:[RxCurrentThreadScheduler sharedInstance] iterate:iterate];
}

+ (nonnull RxObservable *)repeatElement:(nonnull id)element
                              scheduler:(nonnull id <RxImmediateSchedulerType>)scheduler {
    return [[RxRepeatElement alloc] initWithElement:element scheduler:scheduler];
}

+ (nonnull RxObservable *)repeatElement:(nonnull id)element {
    return [self repeatElement:element scheduler:[RxCurrentThreadScheduler sharedInstance]];
}

+ (nonnull RxObservable<id> *)using:(id <RxDisposable>(^)())resourceFactory
                  observableFactory:(RxObservable<id> *(^)(id <RxDisposable>))observableFactory {
    return [[RxUsing alloc] initWithResourceFactory:resourceFactory observableFactory:observableFactory];
}

@end

@implementation RxObservable (Range)

+ (nonnull RxObservable *)range:(nonnull NSNumber *)start
                          count:(NSUInteger)count
                      scheduler:(nonnull id<RxImmediateSchedulerType>)scheduler {
    return [[RxRangeProducer alloc] initWithStart:start count:count scheduler:scheduler];
}

+ (nonnull RxObservable *)range:(nonnull NSNumber *)start
                          count:(NSUInteger)count {
    return [self range:start count:count scheduler:[RxCurrentThreadScheduler sharedInstance]];
}
@end

@implementation NSArray (RxToObservable)

- (nonnull RxObservable *)toObservable:(nullable id <RxImmediateSchedulerType>)scheduler {
    return [[self objectEnumerator] toObservable:scheduler];
}

- (nonnull RxObservable *)toObservable {
    return [self toObservable:nil];
}

@end

@implementation NSSet (RxToObservable)

- (nonnull RxObservable *)toObservable:(nullable id <RxImmediateSchedulerType>)scheduler {
    return [[self objectEnumerator] toObservable:scheduler];
}

- (nonnull RxObservable *)toObservable {
    return [self toObservable:nil];
}

@end

@implementation NSEnumerator (RxToObservable)

- (nonnull RxObservable *)toObservable:(nullable id <RxImmediateSchedulerType>)scheduler {
    return [[RxSequence alloc] initWithElements:self scheduler:scheduler];
}

- (nonnull RxObservable *)toObservable {
    return [self toObservable:nil];
}

@end