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
#import "RxMerge.h"
#import "RxSwitch.h"
#import "RxElementAt.h"
#import "RxSingleAsync.h"

@implementation RxObservable (Filter)

- (nonnull RxObservable *)filter:(nonnull BOOL(^)(id __nonnull))predicate {
    return [[RxFilter alloc] initWithSource:[self asObservable] predicate:predicate];
}

@end

@implementation RxObservable (TakeWhile)

- (nonnull RxObservable *)takeWhile:(nonnull BOOL (^)(id element))predicate {
    return [[RxTakeWhile alloc] initWithSource:[self asObservable] predicate:predicate];
}

- (nonnull RxObservable *)takeWhileWithIndex:(nonnull BOOL (^)(id element, NSUInteger index))predicate {
    return [[RxTakeWhile alloc] initWithSource:[self asObservable] indexPredicate:predicate];
}

@end

@implementation RxObservable (TakeSequence)

- (nonnull RxObservable *)take:(NSUInteger)count {
    if (count == 0) {
        return [RxObservable empty];
    }
    return [[RxTakeCount alloc] initWithSource:[self asObservable] count:count];
}

@end

@implementation RxObservable (TakeLast)

- (nonnull RxObservable *)takeLast:(NSUInteger)count {
    return [[RxTakeLast alloc] initWithSource:[self asObservable] count:count];
}

@end

@implementation RxObservable (SkipSequence)

- (nonnull RxObservable *)skip:(NSUInteger)count {
    return [[RxSkipCount alloc] initWithSource:[self asObservable] count:count];
}

@end

@implementation RxObservable (SkipWhile)

- (nonnull RxObservable *)skipWhile:(nonnull BOOL(^)(id __nonnull element))predicate {
    return [[RxSkipWhile alloc] initWithSource:[self asObservable] predicate:predicate];
}

- (nonnull RxObservable *)skipWhileWithIndex:(nonnull BOOL(^)(id __nonnull element, NSUInteger index))predicate {
    return [[RxSkipWhile alloc] initWithSource:[self asObservable] indexPredicate:predicate];
}

@end

@implementation RxObservable (Map)

- (nonnull RxObservable *)map:(RxMapSelector)mapSelector {
    return [[self asObservable] _composeMap:mapSelector];
}

- (nonnull RxObservable *)mapWithIndex:(RxMapWithIndexSelector)mapSelector {
    return [[RxMapWithIndex alloc] initWithSource:[self asObservable] selector:mapSelector];
}

@end

@implementation RxObservable (FlatMap)

- (nonnull RxObservable *)flatMap:(nonnull id <RxObservableConvertibleType>(^)(id __nonnull element))selector {
    return [[RxFlatMap alloc] initWithSource:[self asObservable] selector:selector];
}

- (nonnull RxObservable *)flatMapWithIndex:(nonnull id <RxObservableConvertibleType>(^)(id __nonnull element, NSUInteger index))selector {
    return [[RxFlatMapWithIndex alloc] initWithSource:[self asObservable] selector:selector];
}

@end

@implementation RxObservable (FlatMapFirst)

- (nonnull RxObservable *)flatMapFirst:(nonnull id <RxObservableConvertibleType>(^)(id __nonnull element))selector {
    return [[RxFlatMapFirst alloc] initWithSource:[self asObservable] selector:selector];
}

@end

@implementation RxObservable (FlatMapLatest)

- (nonnull RxObservable *)flatMapLatest:(nonnull id <RxObservableConvertibleType>(^)(id __nonnull element))selector {
    return [[RxFlatMapLatest alloc] initWithSource:[self asObservable] selector:selector];
}

@end

@implementation RxObservable (ElementAt)

- (nonnull RxObservable *)elementAt:(NSUInteger)index {
    return [[RxElementAt alloc] initWithSource:[self asObservable] index:index throwOnEmpty:YES];
}

@end

@implementation RxObservable (Single)

- (nonnull RxObservable *)single {
    return [[RxSingleAsync alloc] initWithSource:[self asObservable]];
}

- (nonnull RxObservable *)single:(nonnull BOOL(^)(id __nonnull element))predicate {
    return [[RxSingleAsync alloc] initWithSource:[self asObservable] predicate:predicate];
}

@end