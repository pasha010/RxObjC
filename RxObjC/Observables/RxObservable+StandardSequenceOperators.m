//
//  RxObservable(StandardSequenceOperators)
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable+StandardSequenceOperators.h"
#import "RxObservable.h"
#import "RxMap.h"
#import "RxFilter.h"
#import "RxTakeWhile.h"
#import "RxObservable+Creation.h"
#import "RxTake.h"
#import "RxTakeLast.h"
#import "RxSkip.h"
#import "RxSkipWhile.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation NSObject (RxFilter)

- (nonnull RxObservable *)filter:(nonnull BOOL(^)(id __nonnull))predicate {
    return [[RxFilter alloc] initWithSource:[self asObservable] predicate:predicate];
}

@end

@implementation NSObject (RxTakeWhile)

- (nonnull RxObservable *)takeWhile:(nonnull BOOL (^)(id))predicate {
    return [[RxTakeWhile alloc] initWithSource:[self asObservable] predicate:predicate];
}

- (nonnull RxObservable *)takeWhileWithIndex:(nonnull BOOL (^)(id, NSUInteger))predicate {
    return [[RxTakeWhile alloc] initWithSource:[self asObservable] indexPredicate:predicate];
}

@end

@implementation NSObject (RxTake)

- (nonnull RxObservable *)take:(NSUInteger)count {
    if (count == 0) {
        return [RxObservable empty];
    }
    return [[RxTakeCount alloc] initWithSource:[self asObservable] count:count];
}

@end

@implementation NSObject (RxTakeLast)

- (nonnull RxObservable *)takeLast:(NSUInteger)count {
    return [[RxTakeLast alloc] initWithSource:[self asObservable] count:count];
}

@end

@implementation NSObject (RxSkip)

- (nonnull RxObservable *)skip:(NSInteger)count {
    return [[RxSkipCount alloc] initWithSource:[self asObservable] count:count];
}

@end

@implementation NSObject (RxSkipWhile)

- (nonnull RxObservable *)skipWhile:(nonnull BOOL(^)(id __nonnull))predicate {
    return [[RxSkipWhile alloc] initWithSource:[self asObservable] predicate:predicate];
}

- (nonnull RxObservable *)skipWhileWithIndex:(nonnull BOOL(^)(id __nonnull, NSUInteger))predicate {
    return [[RxSkipWhile alloc] initWithSource:[self asObservable] indexPredicate:predicate];
}

@end

@implementation NSObject (RxMap)

- (nonnull RxObservable *)map:(RxMapSelector)mapSelector {
    return [[self asObservable] _composeMap:mapSelector];
}

- (nonnull RxObservable *)mapWithIndex:(RxMapWithIndexSelector)mapSelector {
    return [[RxMapWithIndex alloc] initWithSource:[self asObservable] selector:mapSelector];
}

@end

@implementation NSObject (RxFlatMap)
@end


#pragma clang diagnostic pop