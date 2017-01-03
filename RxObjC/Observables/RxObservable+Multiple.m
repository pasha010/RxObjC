//
//  RxObservable(Multiple)
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable+Multiple.h"
#import "RxConcat.h"
#import "RxMerge.h"
#import "RxObservable+Creation.h"
#import "RxCatch.h"
#import "RxTakeUntil.h"
#import "RxSkipUntil.h"
#import "RxAmb.h"
#import "RxObservable+Aggregate.h"
#import "RxWithLatestFrom.h"
#import "RxCombineLatest+CollectionType.h"
#import "RxZip+CollectionType.h"
#import "RxSwitch.h"
#import "NSEnumerator+Operators.h"

@implementation NSArray (RxCombineLatest)

- (nonnull RxObservable<id> *)combineLatest:(nonnull id(^)(NSArray<id> *__nonnull))resultSelector {
    return [[RxCombineLatestCollectionType alloc] initWithSources:self resultSelector:resultSelector];
}

@end

@implementation NSArray (RxZip)

- (nonnull RxObservable<id> *)zip:(nonnull id(^)(NSArray<id> *__nonnull))resultSelector {
    return [[RxZipCollectionType alloc] initWithSources:self resultSelector:resultSelector];
}

@end

@implementation RxObservable (Switch)

- (nonnull RxObservable<id> *)switchLatest {
    return [[RxSwitch alloc] initWithSource:[self asObservable]];
}

@end

@implementation RxObservable (ConcatWith)

- (nonnull RxObservable<id> *)concatWith:(nonnull id <RxObservableConvertibleType>)second {
    return [@[[self asObservable], [second asObservable]] concat];
}

@end

@implementation NSArray (RxConcat)

- (nonnull RxObservable *)concat {
    return [[self objectEnumerator] concat:self.count];
}

@end

@implementation NSSet (RxConcat)

- (nonnull RxObservable *)concat {
    return [[self objectEnumerator] concat:self.count];
}

@end

@implementation NSEnumerator (RxConcat)

- (nonnull RxObservable *)concat:(NSUInteger)count {
    return [[RxConcat alloc] initWithSources:self count:count];
}

@end

@implementation RxObservable (Concat)

- (nonnull RxObservable<id> *)concat {
    return [self mergeWithMaxConcurrent:1];
}

@end

@implementation RxObservable (Merge)

- (nonnull RxObservable<id> *)merge {
    return [[RxMerge alloc] initWithSource:[self asObservable]];
}

- (nonnull RxObservable<id> *)mergeWithMaxConcurrent:(NSUInteger)maxConcurrent {
    return [[RxMergeLimited alloc] initWithSource:[self asObservable] maxConcurrent:maxConcurrent];
}

@end

@implementation RxObservable (Catch)

- (nonnull RxObservable<id> *)catchError:(RxObservable<id> *(^)(NSError *))handler {
    return [[RxCatch alloc] initWithSource:[self asObservable] handler:handler];
}

- (nonnull RxObservable<id> *)catchErrorJustReturn:(nonnull id)element {
    return [[RxCatch alloc] initWithSource:[self asObservable]
                                   handler:^RxObservable *(NSError *_) {
                                       return [RxObservable just:element];
                                   }];
}

@end

@implementation NSArray (RxCatch)

- (nonnull RxObservable *)catchError {
    return [self.objectEnumerator catchError];
}

@end

@implementation NSSet (RxCatch)

- (nonnull RxObservable *)catchError {
    return [self.objectEnumerator catchError];
}

@end

@implementation NSEnumerator (RxCatch)

- (nonnull RxObservable *)catchError {
    return [[RxCatchSequence alloc] initWithSources:self];
}

@end

@implementation RxObservable (TakeUntil)

- (nonnull RxObservable<id> *)takeUntil:(nonnull id <RxObservableType>)other {
    return [[RxTakeUntil alloc] initWithSource:[self asObservable] other:[other asObservable]];
}

@end

@implementation RxObservable (SkipUntil)

- (nonnull RxObservable<id> *)skipUntil:(nonnull id <RxObservableType>)other {
    return [[RxSkipUntil alloc] initWithSource:[self asObservable] other:[other asObservable]];
}

@end

@implementation RxObservable (Amb)

- (nonnull RxObservable<id> *)amb:(nonnull id <RxObservableType>)right {
    return [[RxAmb alloc] initWithLeft:[self asObservable] right:[right asObservable]];
}

@end

@implementation NSArray (RxAmb)

- (nonnull RxObservable *)amb {
    return [self.objectEnumerator amb];
}

@end

@implementation NSSet (RxAmb)

- (nonnull RxObservable *)amb {
    return [self.objectEnumerator amb];
}

@end

@implementation NSEnumerator (RxAmb)

- (nonnull RxObservable *)amb {
    return [self reduce:[RxObservable never] combine:^RxObservable *(RxObservable *initial, RxObservable *element) {
        return [initial amb:[element asObservable]];
    }];
}

@end

@implementation RxObservable (WithLatestFrom)

- (nonnull RxObservable<id> *)withLatestFrom:(nonnull id <RxObservableConvertibleType>)second
                              resultSelector:(id __nonnull(^)(id __nonnull x, id __nonnull y))resultSelector {

    return [[RxWithLatestFrom alloc] initWithFirst:[self asObservable]
                                            second:[second asObservable]
                                    resultSelector:resultSelector];
}

- (nonnull RxObservable<id> *)withLatestFrom:(nonnull id <RxObservableConvertibleType>)second {
    return [self withLatestFrom:second resultSelector:^id(id o0, id o1) {
        return o1;
    }];
}

@end