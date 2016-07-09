//
//  RxCombineLatest
//  RxObjC
// 
//  Created by Pavel Malkov on 03.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxSink.h"
#import "RxLockOwnerType.h"
#import "RxSynchronizedOnType.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RxCombineLatestProtocol
- (void)next:(NSUInteger)index;
- (void)fail:(nonnull NSError *)error;
- (void)done:(NSUInteger)index;
@end

@interface RxCombineLatestSink<O : id <RxObserverType>> : RxSink<O> <RxCombineLatestProtocol> {
@package
    NSUInteger _arity;
}

- (nonnull instancetype)initWithArity:(NSUInteger)arity observer:(nonnull id <RxObserverType>)observer;

- (nonnull id)getResult;

@end

typedef void (^RxCombineLatestValueSetter)(id __nonnull element);

@interface RxCombineLatestObserver : NSObject <RxObserverType, RxLockOwnerType, RxSynchronizedOnType>

- (nonnull instancetype)initWithLock:(nonnull NSRecursiveLock *)lock
                              parent:(nonnull id <RxCombineLatestProtocol>)parent
                               index:(NSUInteger)index
                      setLatestValue:(RxCombineLatestValueSetter)setLatestValue
                                this:(nonnull id <RxDisposable>)this;
@end

NS_ASSUME_NONNULL_END