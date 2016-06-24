//
//  RxTailRecursiveSink
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxSink.h"
#import "RxTuple.h"
#import "RxInvocableType.h"
#import "RxObjC.h"

@protocol RxObservableConvertibleType;
@class RxObservable;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RxTailRecursiveSinkCommand) {
    RxTailRecursiveSinkCommandMoveNext,
    RxTailRecursiveSinkCommandDispose,
};

#if DEBUG || (defined(TRACE_RESOURCES) && TRACE_RESOURCES)
static NSUInteger rx_maxTailRecursiveSinkStackSize = 0;
#endif

/// This class is usually used with `Generator` version of the operators.
@interface RxTailRecursiveSink : RxSink<id <RxObserverType>> <RxInvocableWithValueType>

- (nonnull instancetype)initWithObserver:(nonnull id <RxObserverType>)observer;

- (nonnull id <RxDisposable>)run:(nonnull RxTuple2<NSEnumerator<id <RxObservableConvertibleType>> *, NSNumber *> *)source;

- (void)schedule:(RxTailRecursiveSinkCommand)command;

- (nullable RxTuple2<NSEnumerator<id <RxObservableConvertibleType>> *, NSNumber *> *)extract:(nonnull RxObservable *)observable;

- (nonnull id <RxDisposable>)subscribeToNext:(nonnull RxObservable *)next;

@end

NS_ASSUME_NONNULL_END