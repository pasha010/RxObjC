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

@interface RxObservable (CombineLatest2)
/**
Merges the specified observable sequences into one observable sequence by using the selector function whenever any of the observable sequences produces an element.

- seealso: [combineLatest operator on reactivex.io](http://reactivex.io/documentation/operators/combinelatest.html)

- parameter resultSelector: Function to invoke whenever any of the sources produces an element.
- returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
*/
+ (nonnull RxObservable *)combineLatest:(nonnull RxObservable *)source1
                                    and:(nonnull RxObservable *)source2
                         resultSelector:(RxCombineLatest2ResultSelector)resultSelector;
@end

@interface RxObservable (CombineLatest3)
+ (nonnull RxObservable *)combineLatest:(nonnull RxObservable *)source1
                                    and:(nonnull RxObservable *)source2
                                    and:(nonnull RxObservable *)source3
                         resultSelector:(RxCombineLatest3ResultSelector)resultSelector;
@end

@interface RxObservable (CombineLatest4)
+ (nonnull RxObservable *)combineLatest:(nonnull RxObservable *)source1
                                    and:(nonnull RxObservable *)source2
                                    and:(nonnull RxObservable *)source3
                                    and:(nonnull RxObservable *)source4
                         resultSelector:(RxCombineLatest4ResultSelector)resultSelector;
@end

@interface RxObservable (CombineLatest5)
+ (nonnull RxObservable *)combineLatest:(nonnull RxObservable *)source1
                                    and:(nonnull RxObservable *)source2
                                    and:(nonnull RxObservable *)source3
                                    and:(nonnull RxObservable *)source4
                                    and:(nonnull RxObservable *)source5
                         resultSelector:(RxCombineLatest5ResultSelector)resultSelector;
@end

@interface RxObservable (CombineLatest6)
+ (nonnull RxObservable *)combineLatest:(nonnull RxObservable *)source1
                                    and:(nonnull RxObservable *)source2
                                    and:(nonnull RxObservable *)source3
                                    and:(nonnull RxObservable *)source4
                                    and:(nonnull RxObservable *)source5
                                    and:(nonnull RxObservable *)source6
                         resultSelector:(RxCombineLatest6ResultSelector)resultSelector;
@end

@interface RxObservable (CombineLatest7)
+ (nonnull RxObservable *)combineLatest:(nonnull RxObservable *)source1
                                    and:(nonnull RxObservable *)source2
                                    and:(nonnull RxObservable *)source3
                                    and:(nonnull RxObservable *)source4
                                    and:(nonnull RxObservable *)source5
                                    and:(nonnull RxObservable *)source6
                                    and:(nonnull RxObservable *)source7
                         resultSelector:(RxCombineLatest7ResultSelector)resultSelector;
@end

@interface RxObservable (CombineLatest8)
+ (nonnull RxObservable *)combineLatest:(nonnull RxObservable *)source1
                                    and:(nonnull RxObservable *)source2
                                    and:(nonnull RxObservable *)source3
                                    and:(nonnull RxObservable *)source4
                                    and:(nonnull RxObservable *)source5
                                    and:(nonnull RxObservable *)source6
                                    and:(nonnull RxObservable *)source7
                                    and:(nonnull RxObservable *)source8
                         resultSelector:(RxCombineLatest8ResultSelector)resultSelector;
@end

@interface RxObservable (CombineLatestArray)
+ (nonnull RxObservable *)combineLatest:(nonnull NSArray<RxObservable *> *)array
                         resultSelector:(RxCombineLatestTupleResultSelector)resultSelector;
@end

NS_ASSUME_NONNULL_END