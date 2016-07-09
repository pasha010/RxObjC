//
//  RxObservable(CombineLatest)
//  RxObjC
// 
//  Created by Pavel Malkov on 09.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable+CombineLatest.h"
#import "RxCombineLatest+Private.h"


@implementation RxObservable (CombineLatest2)

+ (nonnull RxObservable *)combineLatest:(nonnull RxObservable *)source1
                                    and:(nonnull RxObservable *)source2
                         resultSelector:(RxCombineLatest2ResultSelector)resultSelector {
    return [[RxCombineLatest2 alloc] initWithSource1:[source1 asObservable] source2:[source2 asObservable] resultSelector:resultSelector];
}
@end

@implementation RxObservable (CombineLatest3)
+ (nonnull RxObservable *)combineLatest:(nonnull RxObservable *)source1
                                    and:(nonnull RxObservable *)source2
                                    and:(nonnull RxObservable *)source3
                         resultSelector:(RxCombineLatest3ResultSelector)resultSelector {
    return [[RxCombineLatest3 alloc] initWithSource1:[source1 asObservable]
                                             source2:[source2 asObservable]
                                             source3:[source3 asObservable]
                                      resultSelector:resultSelector];
}
@end

@implementation RxObservable (CombineLatest4)
+ (nonnull RxObservable *)combineLatest:(nonnull RxObservable *)source1
                                    and:(nonnull RxObservable *)source2
                                    and:(nonnull RxObservable *)source3
                                    and:(nonnull RxObservable *)source4
                         resultSelector:(RxCombineLatest4ResultSelector)resultSelector {
    return [[RxCombineLatest4 alloc] initWithSource1:[source1 asObservable]
                                             source2:[source2 asObservable]
                                             source3:[source3 asObservable]
                                             source4:[source4 asObservable]
                                      resultSelector:resultSelector];
}
@end

@implementation RxObservable (CombineLatest5)
+ (nonnull RxObservable *)combineLatest:(nonnull RxObservable *)source1
                                    and:(nonnull RxObservable *)source2
                                    and:(nonnull RxObservable *)source3
                                    and:(nonnull RxObservable *)source4
                                    and:(nonnull RxObservable *)source5
                         resultSelector:(RxCombineLatest5ResultSelector)resultSelector {
    return [[RxCombineLatest5 alloc] initWithSource1:[source1 asObservable]
                                             source2:[source2 asObservable]
                                             source3:[source3 asObservable]
                                             source4:[source4 asObservable]
                                             source5:[source5 asObservable]
                                      resultSelector:resultSelector];
}
@end

@implementation RxObservable (CombineLatest6)
+ (nonnull RxObservable *)combineLatest:(nonnull RxObservable *)source1
                                    and:(nonnull RxObservable *)source2
                                    and:(nonnull RxObservable *)source3
                                    and:(nonnull RxObservable *)source4
                                    and:(nonnull RxObservable *)source5
                                    and:(nonnull RxObservable *)source6
                         resultSelector:(RxCombineLatest6ResultSelector)resultSelector {
    return [[RxCombineLatest6 alloc] initWithSource1:[source1 asObservable]
                                             source2:[source2 asObservable]
                                             source3:[source3 asObservable]
                                             source4:[source4 asObservable]
                                             source5:[source5 asObservable]
                                             source6:[source6 asObservable]
                                      resultSelector:resultSelector];
}
@end

@implementation RxObservable (CombineLatest7)
+ (nonnull RxObservable *)combineLatest:(nonnull RxObservable *)source1
                                    and:(nonnull RxObservable *)source2
                                    and:(nonnull RxObservable *)source3
                                    and:(nonnull RxObservable *)source4
                                    and:(nonnull RxObservable *)source5
                                    and:(nonnull RxObservable *)source6
                                    and:(nonnull RxObservable *)source7
                         resultSelector:(RxCombineLatest7ResultSelector)resultSelector {
    return [[RxCombineLatest7 alloc] initWithSource1:[source1 asObservable]
                                             source2:[source2 asObservable]
                                             source3:[source3 asObservable]
                                             source4:[source4 asObservable]
                                             source5:[source5 asObservable]
                                             source6:[source6 asObservable]
                                             source7:[source7 asObservable]
                                      resultSelector:resultSelector];
}
@end

@implementation RxObservable (CombineLatest8)
+ (nonnull RxObservable *)combineLatest:(nonnull RxObservable *)source1
                                    and:(nonnull RxObservable *)source2
                                    and:(nonnull RxObservable *)source3
                                    and:(nonnull RxObservable *)source4
                                    and:(nonnull RxObservable *)source5
                                    and:(nonnull RxObservable *)source6
                                    and:(nonnull RxObservable *)source7
                                    and:(nonnull RxObservable *)source8
                         resultSelector:(RxCombineLatest8ResultSelector)resultSelector {
    return [[RxCombineLatest8 alloc] initWithSource1:[source1 asObservable]
                                             source2:[source2 asObservable]
                                             source3:[source3 asObservable]
                                             source4:[source4 asObservable]
                                             source5:[source5 asObservable]
                                             source6:[source6 asObservable]
                                             source7:[source7 asObservable]
                                             source8:[source8 asObservable]
                                      resultSelector:resultSelector];
}
@end

@implementation RxObservable (CombineLatestArray)

+ (nonnull RxObservable *)combineLatest:(nonnull NSArray<RxObservable *> *)sources
                         resultSelector:(RxCombineLatestTupleResultSelector)resultSelector {
    return [[RxCombineLatestArray alloc] initWithSources:sources resultSelector:resultSelector];
}

@end