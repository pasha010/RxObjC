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

@interface RxObservable (Zip)

/**
Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

- seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

- parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
- returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
*/
+ (nonnull RxObservable *)zip:(nonnull id <RxObservableType>)source1
                          and:(nonnull id <RxObservableType>)source2
               resultSelector:(RxZip2ResultSelector)resultSelector;

@end

@interface RxObservable (Zip3)

+ (nonnull RxObservable *)zip:(nonnull id <RxObservableType>)source1
                          and:(nonnull id <RxObservableType>)source2
                          and:(nonnull id <RxObservableType>)source3
               resultSelector:(RxZip3ResultSelector)resultSelector;

@end

@interface RxObservable (Zip4)

+ (nonnull RxObservable *)zip:(nonnull id <RxObservableType>)source1
                          and:(nonnull id <RxObservableType>)source2
                          and:(nonnull id <RxObservableType>)source3
                          and:(nonnull id <RxObservableType>)source4
               resultSelector:(RxZip4ResultSelector)resultSelector;

@end

@interface RxObservable (Zip5)

+ (nonnull RxObservable *)zip:(nonnull id <RxObservableType>)source1
                          and:(nonnull id <RxObservableType>)source2
                          and:(nonnull id <RxObservableType>)source3
                          and:(nonnull id <RxObservableType>)source4
                          and:(nonnull id <RxObservableType>)source5
               resultSelector:(RxZip5ResultSelector)resultSelector;

@end

@interface RxObservable (Zip6)

+ (nonnull RxObservable *)zip:(nonnull id <RxObservableType>)source1
                          and:(nonnull id <RxObservableType>)source2
                          and:(nonnull id <RxObservableType>)source3
                          and:(nonnull id <RxObservableType>)source4
                          and:(nonnull id <RxObservableType>)source5
                          and:(nonnull id <RxObservableType>)source6
               resultSelector:(RxZip6ResultSelector)resultSelector;

@end

@interface RxObservable (Zip7)

+ (nonnull RxObservable *)zip:(nonnull id <RxObservableType>)source1
                          and:(nonnull id <RxObservableType>)source2
                          and:(nonnull id <RxObservableType>)source3
                          and:(nonnull id <RxObservableType>)source4
                          and:(nonnull id <RxObservableType>)source5
                          and:(nonnull id <RxObservableType>)source6
                          and:(nonnull id <RxObservableType>)source7
               resultSelector:(RxZip7ResultSelector)resultSelector;

@end

@interface RxObservable (Zip8)

+ (nonnull RxObservable *)zip:(nonnull id <RxObservableType>)source1
                          and:(nonnull id <RxObservableType>)source2
                          and:(nonnull id <RxObservableType>)source3
                          and:(nonnull id <RxObservableType>)source4
                          and:(nonnull id <RxObservableType>)source5
                          and:(nonnull id <RxObservableType>)source6
                          and:(nonnull id <RxObservableType>)source7
                          and:(nonnull id <RxObservableType>)source8
               resultSelector:(RxZip8ResultSelector)resultSelector;

@end

@interface RxObservable (ZipArray)

+ (nonnull RxObservable *)zip:(nonnull NSArray<id <RxObservableType>> *)sources
               resultSelector:(RxZipTupleResultSelector)resultSelector;

@end

NS_ASSUME_NONNULL_END