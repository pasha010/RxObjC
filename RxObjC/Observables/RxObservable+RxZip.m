//
//  RxObservable(RxZip)
//  RxObjC
// 
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable+RxZip.h"
#import "RxSink.h"
#import "RxZip.h"
#import "RxZip+Private.h"

@implementation RxObservable (RxZip)

+ (nonnull RxObservable *)zip:(nonnull id <RxObservableType>)source1
                          and:(nonnull id <RxObservableType>)source2
               resultSelector:(RxZip2ResultSelector)resultSelector {
    return [[RxZip2 alloc] initWithSource1:[source1 asObservable] and:[source2 asObservable] resultSelector:resultSelector];
}

@end

@implementation RxObservable (RxZip3)
+ (nonnull RxObservable *)zip:(nonnull id <RxObservableType>)source1
                          and:(nonnull id <RxObservableType>)source2
                          and:(nonnull id <RxObservableType>)source3
               resultSelector:(RxZip3ResultSelector)resultSelector {
    return [[RxZip3 alloc] initWithSource1:[source1 asObservable] and:[source2 asObservable] and:[source3 asObservable] resultSelector:resultSelector];
}


@end
