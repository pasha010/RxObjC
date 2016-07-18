//
//  RxObservable(RxZip)
//  RxObjC
// 
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservable.h"
#import "RxObservableBlockTypedef.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxObservable<E> (Zip)
/**
 * Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.
 * @see [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)
 * @param source1: first observable
 * @param source2: second observable
 * @param resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
 * @return: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
 */
+ (nonnull RxObservable<E> *)zip:(nonnull id <RxObservableType>)source1
                             and:(nonnull id <RxObservableType>)source2
                  resultSelector:(RxZip2ResultSelector)resultSelector;

@end

@interface RxObservable<E> (Zip3)

+ (nonnull RxObservable<E> *)zip:(nonnull id <RxObservableType>)source1
                             and:(nonnull id <RxObservableType>)source2
                             and:(nonnull id <RxObservableType>)source3
                  resultSelector:(RxZip3ResultSelector)resultSelector;

@end

@interface RxObservable<E> (Zip4)

+ (nonnull RxObservable<E> *)zip:(nonnull id <RxObservableType>)source1
                             and:(nonnull id <RxObservableType>)source2
                             and:(nonnull id <RxObservableType>)source3
                             and:(nonnull id <RxObservableType>)source4
                  resultSelector:(RxZip4ResultSelector)resultSelector;

@end

@interface RxObservable<E> (Zip5)

+ (nonnull RxObservable<E> *)zip:(nonnull id <RxObservableType>)source1
                             and:(nonnull id <RxObservableType>)source2
                             and:(nonnull id <RxObservableType>)source3
                             and:(nonnull id <RxObservableType>)source4
                             and:(nonnull id <RxObservableType>)source5
                  resultSelector:(RxZip5ResultSelector)resultSelector;

@end

@interface RxObservable<E> (Zip6)

+ (nonnull RxObservable<E> *)zip:(nonnull id <RxObservableType>)source1
                             and:(nonnull id <RxObservableType>)source2
                             and:(nonnull id <RxObservableType>)source3
                             and:(nonnull id <RxObservableType>)source4
                             and:(nonnull id <RxObservableType>)source5
                             and:(nonnull id <RxObservableType>)source6
                  resultSelector:(RxZip6ResultSelector)resultSelector;

@end

@interface RxObservable<E> (Zip7)

+ (nonnull RxObservable<E> *)zip:(nonnull id <RxObservableType>)source1
                             and:(nonnull id <RxObservableType>)source2
                             and:(nonnull id <RxObservableType>)source3
                             and:(nonnull id <RxObservableType>)source4
                             and:(nonnull id <RxObservableType>)source5
                             and:(nonnull id <RxObservableType>)source6
                             and:(nonnull id <RxObservableType>)source7
                  resultSelector:(RxZip7ResultSelector)resultSelector;

@end

@interface RxObservable<E> (Zip8)

+ (nonnull RxObservable<E> *)zip:(nonnull id <RxObservableType>)source1
                             and:(nonnull id <RxObservableType>)source2
                             and:(nonnull id <RxObservableType>)source3
                             and:(nonnull id <RxObservableType>)source4
                             and:(nonnull id <RxObservableType>)source5
                             and:(nonnull id <RxObservableType>)source6
                             and:(nonnull id <RxObservableType>)source7
                             and:(nonnull id <RxObservableType>)source8
                  resultSelector:(RxZip8ResultSelector)resultSelector;

@end

@interface RxObservable<E> (ZipArray)

+ (nonnull RxObservable<E> *)zip:(nonnull NSArray<id <RxObservableType>> *)sources
                  resultSelector:(RxZipTupleResultSelector)resultSelector;

@end

NS_ASSUME_NONNULL_END