//
//  RxZip
//  RxObjC
// 
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxSink.h"
#import "RxLockOwnerType.h"
#import "RxSynchronizedOnType.h"
#import "RxObservableBlockTypedef.h"

@protocol RxObserverType;

NS_ASSUME_NONNULL_BEGIN

@protocol RxZipSinkProtocol <NSObject>
- (void)next:(NSUInteger)index;

- (void)fail:(nonnull NSError *)error;

- (void)done:(NSUInteger)index;
@end

@interface RxZipSink<O : id <RxObserverType>> : RxSink<O> <RxZipSinkProtocol>

- (nonnull instancetype)initWithArity:(NSUInteger)arity andObserver:(nonnull id <RxObserverType>)observer;
- (nonnull id)getResult;
- (BOOL)hasElements:(NSUInteger)index;

@end

@interface RxZipObserver<ElementType> : NSObject <RxObserverType, RxLockOwnerType, RxSynchronizedOnType>

- (nonnull instancetype)initWithLock:(nonnull NSRecursiveLock *)lock
                              parent:(nonnull id<RxZipSinkProtocol>)parent
                               index:(NSUInteger)index
                        setNextValue:(RxZipObserverValueSetter)setNextValue
                                this:(nonnull id <RxDisposable>)this;

@end

NS_ASSUME_NONNULL_END