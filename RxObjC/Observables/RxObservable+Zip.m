//
//  RxObservable(RxZip)
//  RxObjC
// 
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable+Zip.h"
#import "RxSink.h"
#import "RxZip.h"
#import "RxZip+Private.h"

@implementation RxObservable (Zip)

+ (nonnull RxObservable *)zip:(nonnull id <RxObservableType>)source1
                          and:(nonnull id <RxObservableType>)source2
               resultSelector:(RxZip2ResultSelector)resultSelector {
    return [[RxZip2 alloc] initWithSource1:[source1 asObservable] and:[source2 asObservable] resultSelector:resultSelector];
}

@end

@implementation RxObservable (Zip3)

+ (nonnull RxObservable *)zip:(nonnull id <RxObservableType>)source1
                          and:(nonnull id <RxObservableType>)source2
                          and:(nonnull id <RxObservableType>)source3
               resultSelector:(RxZip3ResultSelector)resultSelector {
    return [[RxZip3 alloc] initWithSource1:[source1 asObservable] and:[source2 asObservable] and:[source3 asObservable] resultSelector:resultSelector];
}

@end



@implementation RxObservable (Zip4)

+ (nonnull RxObservable *)zip:(nonnull id <RxObservableType>)source1
                          and:(nonnull id <RxObservableType>)source2
                          and:(nonnull id <RxObservableType>)source3
                          and:(nonnull id <RxObservableType>)source4
               resultSelector:(RxZip4ResultSelector)resultSelector {
    return [[RxZip4 alloc] initWithSource1:source1 and:source2 and:source3 and:source4 resultSelector:resultSelector];
}

@end

@implementation RxObservable (Zip5)

+ (nonnull RxObservable *)zip:(nonnull id <RxObservableType>)source1
                          and:(nonnull id <RxObservableType>)source2
                          and:(nonnull id <RxObservableType>)source3
                          and:(nonnull id <RxObservableType>)source4
                          and:(nonnull id <RxObservableType>)source5
               resultSelector:(RxZip5ResultSelector)resultSelector {
    return [[RxZip5 alloc] initWithSource1:source1 and:source2 and:source3 and:source4 and:source5 resultSelector:resultSelector];
}

@end

@implementation RxObservable (Zip6)

+ (nonnull RxObservable *)zip:(nonnull id <RxObservableType>)source1
                          and:(nonnull id <RxObservableType>)source2
                          and:(nonnull id <RxObservableType>)source3
                          and:(nonnull id <RxObservableType>)source4
                          and:(nonnull id <RxObservableType>)source5
                          and:(nonnull id <RxObservableType>)source6
               resultSelector:(RxZip6ResultSelector)resultSelector {
    return [[RxZip6 alloc] initWithSource1:source1 and:source2 and:source3 and:source4 and:source5 and:source6 resultSelector:resultSelector];

}

@end

@implementation RxObservable (Zip7)

+ (nonnull RxObservable *)zip:(nonnull id <RxObservableType>)source1
                          and:(nonnull id <RxObservableType>)source2
                          and:(nonnull id <RxObservableType>)source3
                          and:(nonnull id <RxObservableType>)source4
                          and:(nonnull id <RxObservableType>)source5
                          and:(nonnull id <RxObservableType>)source6
                          and:(nonnull id <RxObservableType>)source7
               resultSelector:(RxZip7ResultSelector)resultSelector {
    return [[RxZip7 alloc] initWithSource1:source1 and:source2 and:source3 and:source4 and:source5 and:source6 and:source7 resultSelector:resultSelector];
}

@end

@implementation RxObservable (Zip8)

+ (nonnull RxObservable *)zip:(nonnull id <RxObservableType>)source1
                          and:(nonnull id <RxObservableType>)source2
                          and:(nonnull id <RxObservableType>)source3
                          and:(nonnull id <RxObservableType>)source4
                          and:(nonnull id <RxObservableType>)source5
                          and:(nonnull id <RxObservableType>)source6
                          and:(nonnull id <RxObservableType>)source7
                          and:(nonnull id <RxObservableType>)source8
               resultSelector:(RxZip8ResultSelector)resultSelector {
    return [[RxZip8 alloc] initWithSource1:source1 and:source2 and:source3 and:source4 and:source5 and:source6 and:source7 and:source8 resultSelector:resultSelector];
}

@end

@implementation RxObservable (ZipArray)

+ (nonnull RxObservable *)zip:(nonnull NSArray<id <RxObservableType>> *)sources
               resultSelector:(RxZipTupleResultSelector)resultSelector {
    return [[RxZipArray alloc] initWithSources:sources resultSelector:resultSelector];
}

@end
