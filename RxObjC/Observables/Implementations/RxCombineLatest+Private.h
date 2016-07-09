//
//  RxCombineLatest(Private)
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxCombineLatest.h"
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxCombineLatestArray<R> : RxProducer<R> {
@package
    NSArray<RxObservable<id> *> *__nonnull _sources;
    RxCombineLatestTupleResultSelector _resultSelector;
}

- (nonnull instancetype)initWithSources:(nonnull NSArray<RxObservable<id> *> *)sources
                         resultSelector:(RxCombineLatestTupleResultSelector)resultSelector;


@end

@interface RxCombineLatest2<E1, E2, R> : RxCombineLatestArray <R>

- (nonnull instancetype)initWithSource1:(nonnull RxObservable<E1> *)source1
                                source2:(nonnull RxObservable<E2> *)source2
                         resultSelector:(RxCombineLatest2ResultSelector)resultSelector;

@end

@interface RxCombineLatest3<E1, E2, E3, R> : RxCombineLatestArray <R>

- (nonnull instancetype)initWithSource1:(nonnull RxObservable<E1> *)source1
                                source2:(nonnull RxObservable<E2> *)source2
                                source3:(nonnull RxObservable<E3> *)source23
                         resultSelector:(RxCombineLatest3ResultSelector)resultSelector;

@end

@interface RxCombineLatest4<E1, E2, E3, E4, R> : RxCombineLatestArray <R>

- (nonnull instancetype)initWithSource1:(nonnull RxObservable<E1> *)source1
                                source2:(nonnull RxObservable<E2> *)source2
                                source3:(nonnull RxObservable<E3> *)source3
                                source4:(nonnull RxObservable<E4> *)source4
                         resultSelector:(RxCombineLatest4ResultSelector)resultSelector;

@end

@interface RxCombineLatest5<E1, E2, E3, E4, E5, R> : RxCombineLatestArray <R>

- (nonnull instancetype)initWithSource1:(nonnull RxObservable<E1> *)source1
                                source2:(nonnull RxObservable<E2> *)source2
                                source3:(nonnull RxObservable<E3> *)source3
                                source4:(nonnull RxObservable<E4> *)source4
                                source5:(nonnull RxObservable<E5> *)source5
                         resultSelector:(RxCombineLatest5ResultSelector)resultSelector;

@end

@interface RxCombineLatest6<E1, E2, E3, E4, E5, E6, R> : RxCombineLatestArray <R>

- (nonnull instancetype)initWithSource1:(nonnull RxObservable<E1> *)source1
                                source2:(nonnull RxObservable<E2> *)source2
                                source3:(nonnull RxObservable<E3> *)source3
                                source4:(nonnull RxObservable<E4> *)source4
                                source5:(nonnull RxObservable<E5> *)source5
                                source6:(nonnull RxObservable<E6> *)source6
                         resultSelector:(RxCombineLatest6ResultSelector)resultSelector;

@end

@interface RxCombineLatest7<E1, E2, E3, E4, E5, E6, E7, R> : RxCombineLatestArray <R>

- (nonnull instancetype)initWithSource1:(nonnull RxObservable<E1> *)source1
                                source2:(nonnull RxObservable<E2> *)source2
                                source3:(nonnull RxObservable<E3> *)source3
                                source4:(nonnull RxObservable<E4> *)source4
                                source5:(nonnull RxObservable<E5> *)source5
                                source6:(nonnull RxObservable<E6> *)source6
                                source7:(nonnull RxObservable<E7> *)source7
                         resultSelector:(RxCombineLatest7ResultSelector)resultSelector;

@end

@interface RxCombineLatest8<E1, E2, E3, E4, E5, E6, E7, E8, R> : RxCombineLatestArray <R>

- (nonnull instancetype)initWithSource1:(nonnull RxObservable<E1> *)source1
                                source2:(nonnull RxObservable<E2> *)source2
                                source3:(nonnull RxObservable<E3> *)source3
                                source4:(nonnull RxObservable<E4> *)source4
                                source5:(nonnull RxObservable<E5> *)source5
                                source6:(nonnull RxObservable<E6> *)source6
                                source7:(nonnull RxObservable<E7> *)source7
                                source8:(nonnull RxObservable<E8> *)source8
                         resultSelector:(RxCombineLatest8ResultSelector)resultSelector;

@end

NS_ASSUME_NONNULL_END