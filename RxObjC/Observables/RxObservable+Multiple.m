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


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma GCC diagnostic ignored "-Wprotocol"

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

@implementation NSObject (RxSwitch)

- (nonnull RxObservable *)switchLatest {
    return [[RxSwitch alloc] initWithSource:[self asObservable]];
}

@end

@implementation NSObject (RxConcatWith)

- (nonnull RxObservable *)concatWith:(nonnull RxObservable *)second {
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

@implementation NSObject (RxConcat)

- (nonnull RxObservable *)concat {
    return [self mergeWithMaxConcurrent:1];
}

@end

@implementation NSObject (RxMerge)

- (nonnull RxObservable *)merge {
    return [[RxMerge alloc] initWithSource:[self asObservable]];
}

- (nonnull RxObservable *)mergeWithMaxConcurrent:(NSUInteger)maxConcurrent {
    return [[RxMergeLimited alloc] initWithSource:[self asObservable] maxConcurrent:maxConcurrent];
}

@end

@implementation NSObject (RxCatch)

- (nonnull RxObservable *)catchError:(RxObservable *(^)(NSError *))handler {
    return [[RxCatch alloc] initWithSource:[self asObservable] handler:handler];
}

- (nonnull RxObservable *)catchErrorJustReturn:(nonnull id)element {
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

@implementation NSObject (RxTakeUntil)

- (nonnull RxObservable *)takeUntil:(nonnull id <RxObservableType>)other {
    return [[RxTakeUntil alloc] initWithSource:[self asObservable] other:[other asObservable]];
}

@end

@implementation NSObject (RxSkipUntil)

- (nonnull RxObservable *)skipUntil:(nonnull id <RxObservableType>)other {
    return [[RxSkipUntil alloc] initWithSource:[self asObservable] other:[other asObservable]];
}

@end

@implementation NSObject (RxAmb)

- (nonnull RxObservable *)amb:(nonnull id <RxObservableType>)right {
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

@implementation NSObject (RxWithLatestFrom)

- (nonnull RxObservable *)withLatestFrom:(nonnull id <RxObservableConvertibleType>)second
                          resultSelector:(id __nonnull(^)(id __nonnull x, id __nonnull y))resultSelector {

    return [[RxWithLatestFrom alloc] initWithFirst:[self asObservable]
                                            second:[second asObservable]
                                    resultSelector:resultSelector];
}

- (nonnull RxObservable *)withLatestFrom:(nonnull id <RxObservableConvertibleType>)second {
    return [self withLatestFrom:second resultSelector:^id(id o0, id o1) {
        return o1;
    }];
}

@end

#pragma clang diagnostic pop