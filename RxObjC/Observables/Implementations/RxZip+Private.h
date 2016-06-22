//
//  RxZip(Private)
//  RxObjC
// 
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"
#import "RxObservableBlockTypedef.h"
#import "RxZip.h"

NS_ASSUME_NONNULL_BEGIN

// I think implementation without Block trampoline like RAC is better

/// array

@interface RxZipArray<R> : RxProducer<R>

@property (copy, readonly) RxZipTupleResultSelector tupleResultSelector;
@property (nonnull, strong, readonly) NSArray<RxObservable *> *sources;

- (nonnull instancetype)initWithSources:(nonnull NSArray<RxObservable *> *)sources resultSelector:(RxZipTupleResultSelector)resultSelector;

@end

@interface RxZipArraySink<O : id <RxObserverType>> : RxZipSink<O>

- (nonnull instancetype)initWithParent:(nonnull RxZipArray *)parent andObserver:(nonnull id <RxObserverType>)observer;

@end

/// 2

@interface RxZip2<E1, E2, R> : RxZipArray<R>

- (nonnull instancetype)initWithSource1:(nonnull RxObservable<E1> *)source1 and:(nonnull RxObservable<E2> *)source2 resultSelector:(RxZip2ResultSelector)resultSelector;

@end

/// 3

@interface RxZip3<E1, E2, E3, R> : RxZipArray<R>

- (nonnull instancetype)initWithSource1:(nonnull RxObservable<E1> *)source1 and:(nonnull RxObservable<E2> *)source2 and:(nonnull RxObservable<E3> *)source3 resultSelector:(RxZip3ResultSelector)resultSelector;

@end

/// 4

@interface RxZip4<E1, E2, E3, E4, R> : RxZipArray<R>

- (nonnull instancetype)initWithSource1:(nonnull RxObservable<E1> *)source1 and:(nonnull RxObservable<E2> *)source2 and:(nonnull RxObservable<E3> *)source3 and:(nonnull RxObservable<E4> *)source4 resultSelector:(RxZip4ResultSelector)resultSelector;

@end

/// 7

@interface RxZip7<R> : RxZipArray<R>

- (nonnull instancetype)initWithSource1:(nonnull RxObservable *)source1 and:(nonnull RxObservable *)source2 and:(nonnull RxObservable *)source3 and:(nonnull RxObservable *)source4 and:(nonnull RxObservable *)source5 and:(nonnull RxObservable *)source6 and:(nonnull RxObservable *)source7 resultSelector:(RxZip7ResultSelector)resultSelector;

@end

/// 8

@interface RxZip8<R> : RxZipArray<R>
- (nonnull instancetype)initWithSource1:(nonnull RxObservable *)source1 and:(nonnull RxObservable *)source2 and:(nonnull RxObservable *)source3 and:(nonnull RxObservable *)source4 and:(nonnull RxObservable *)source5 and:(nonnull RxObservable *)source6 and:(nonnull RxObservable *)source7 and:(nonnull RxObservable *)source8 resultSelector:(RxZip8ResultSelector)resultSelector;

@end

/*@interface RxZip8Sink<O : id<RxObserverType>> : RxZipSink<O>
@end

@interface RxZip8<R> : RxProducer<R>
// private source
@property (nonnull, strong, readonly) id source1;
@property (nonnull, strong, readonly) id source2;
@property (nonnull, strong, readonly) id source3;
@property (nonnull, strong, readonly) id source4;
@property (nonnull, strong, readonly) id source5;
@property (nonnull, strong, readonly) id source6;
@property (nonnull, strong, readonly) id source7;
@property (nonnull, strong, readonly) id source8;
@property (copy, readonly) RxZip8ResultSelector resultSelector;
@end*/

NS_ASSUME_NONNULL_END