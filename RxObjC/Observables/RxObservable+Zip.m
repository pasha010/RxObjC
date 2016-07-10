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
    return [[RxZip4 alloc] initWithSource1:[source1 asObservable] and:[source2 asObservable] and:[source3 asObservable] and:[source4 asObservable] resultSelector:resultSelector];
}

@end

@implementation RxObservable (Zip5)

+ (nonnull RxObservable *)zip:(nonnull id <RxObservableType>)source1
                          and:(nonnull id <RxObservableType>)source2
                          and:(nonnull id <RxObservableType>)source3
                          and:(nonnull id <RxObservableType>)source4
                          and:(nonnull id <RxObservableType>)source5
               resultSelector:(RxZip5ResultSelector)resultSelector {
    return [[RxZip5 alloc] initWithSource1:[source1 asObservable] and:[source2 asObservable] and:[source3 asObservable] and:[source4 asObservable] and:[source5 asObservable] resultSelector:resultSelector];
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
    return [[RxZip6 alloc] initWithSource1:[source1 asObservable] and:[source2 asObservable] and:[source3 asObservable] and:[source4 asObservable] and:[source5 asObservable] and:[source6 asObservable] resultSelector:resultSelector];

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
    return [[RxZip7 alloc] initWithSource1:[source1 asObservable] and:[source2 asObservable] and:[source3 asObservable] and:[source4 asObservable] and:[source5 asObservable] and:[source6 asObservable] and:[source7 asObservable] resultSelector:resultSelector];
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
    return [[RxZip8 alloc] initWithSource1:[source1 asObservable] and:[source2 asObservable] and:[source3 asObservable] and:[source4 asObservable] and:[source5 asObservable] and:[source6 asObservable] and:[source7 asObservable] and:[source8 asObservable] resultSelector:resultSelector];
}

@end

@implementation RxObservable (ZipArray)

+ (nonnull RxObservable *)zip:(nonnull NSArray<id <RxObservableType>> *)sources
               resultSelector:(RxZipTupleResultSelector)resultSelector {
    NSMutableArray<RxObservable *> *observables = [NSMutableArray arrayWithCapacity:sources.count];
    for (id <RxObservableType> s in sources) {
        [observables addObject:[s asObservable]];
    }
    return [[RxZipArray alloc] initWithSources:observables resultSelector:resultSelector];
}

@end
