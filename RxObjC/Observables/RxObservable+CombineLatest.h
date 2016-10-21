//
//  RxObservable(CombineLatest)
//  RxObjC
// 
//  Created by Pavel Malkov on 09.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservable.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxObservable<E> (CombineLatest2)
/**
 * Merges the specified observable sequences into one observable sequence by using the selector function whenever any of the observable sequences produces an element.
 * @param source1 - first observable
 * @param source2 - second observable
 * @param resultSelector - Function to invoke whenever any of the sources produces an element.
 * @return: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
 */
+ (nonnull RxObservable<E> *)combineLatest:(nonnull id <RxObservableType>)source1
                                       and:(nonnull id <RxObservableType>)source2
                            resultSelector:(RxCombineLatest2ResultSelector)resultSelector;
@end

@interface RxObservable<E> (CombineLatest3)
+ (nonnull RxObservable<E> *)combineLatest:(nonnull id <RxObservableType>)source1
                                       and:(nonnull id <RxObservableType>)source2
                                       and:(nonnull id <RxObservableType>)source3
                            resultSelector:(RxCombineLatest3ResultSelector)resultSelector;
@end

@interface RxObservable<E> (CombineLatest4)
+ (nonnull RxObservable<E> *)combineLatest:(nonnull id <RxObservableType>)source1
                                       and:(nonnull id <RxObservableType>)source2
                                       and:(nonnull id <RxObservableType>)source3
                                       and:(nonnull id <RxObservableType>)source4
                            resultSelector:(RxCombineLatest4ResultSelector)resultSelector;
@end

@interface RxObservable<E> (CombineLatest5)
+ (nonnull RxObservable<E> *)combineLatest:(nonnull id <RxObservableType>)source1
                                       and:(nonnull id <RxObservableType>)source2
                                       and:(nonnull id <RxObservableType>)source3
                                       and:(nonnull id <RxObservableType>)source4
                                       and:(nonnull id <RxObservableType>)source5
                            resultSelector:(RxCombineLatest5ResultSelector)resultSelector;
@end

@interface RxObservable<E> (CombineLatest6)
+ (nonnull RxObservable<E> *)combineLatest:(nonnull id <RxObservableType>)source1
                                       and:(nonnull id <RxObservableType>)source2
                                       and:(nonnull id <RxObservableType>)source3
                                       and:(nonnull id <RxObservableType>)source4
                                       and:(nonnull id <RxObservableType>)source5
                                       and:(nonnull id <RxObservableType>)source6
                            resultSelector:(RxCombineLatest6ResultSelector)resultSelector;
@end

@interface RxObservable<E> (CombineLatest7)
+ (nonnull RxObservable<E> *)combineLatest:(nonnull id <RxObservableType>)source1
                                       and:(nonnull id <RxObservableType>)source2
                                       and:(nonnull id <RxObservableType>)source3
                                       and:(nonnull id <RxObservableType>)source4
                                       and:(nonnull id <RxObservableType>)source5
                                       and:(nonnull id <RxObservableType>)source6
                                       and:(nonnull id <RxObservableType>)source7
                            resultSelector:(RxCombineLatest7ResultSelector)resultSelector;
@end

@interface RxObservable<E> (CombineLatest8)
+ (nonnull RxObservable<E> *)combineLatest:(nonnull id <RxObservableType>)source1
                                       and:(nonnull id <RxObservableType>)source2
                                       and:(nonnull id <RxObservableType>)source3
                                       and:(nonnull id <RxObservableType>)source4
                                       and:(nonnull id <RxObservableType>)source5
                                       and:(nonnull id <RxObservableType>)source6
                                       and:(nonnull id <RxObservableType>)source7
                                       and:(nonnull id <RxObservableType>)source8
                            resultSelector:(RxCombineLatest8ResultSelector)resultSelector;
@end

@interface RxObservable<E> (CombineLatestArray)
+ (nonnull RxObservable<E> *)combineLatest:(nonnull NSArray<id <RxObservableType>> *)array
                            resultSelector:(RxCombineLatestTupleResultSelector)resultSelector;
@end

NS_ASSUME_NONNULL_END