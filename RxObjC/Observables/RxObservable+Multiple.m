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


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation NSArray (RxCombineLatest)

- (nonnull RxObservable *)combineLatest:(nonnull id(^)(NSArray *__nonnull))resultSelector {
    return [[RxCombineLatestCollectionType alloc] initWithSources:self resultSelector:resultSelector];
}

@end

@implementation RxObservable (Concat)

+ (nonnull RxObservable *)concatWith:(nonnull RxObservable *)second {
    return [@[[self asObservable], [second asObservable]] concat];
}

@end

@implementation NSArray (RxConcat)

- (nonnull RxObservable *)concat {
    return [[self objectEnumerator] concat];
}

@end

@implementation NSSet (RxConcat)

- (nonnull RxObservable *)concat {
    return [[self objectEnumerator] concat];
}

@end

@implementation NSEnumerator (RxConcat)

- (nonnull RxObservable *)concat {
    return [[RxConcat alloc] initWithSources:self];
}

@end

@implementation NSObject (RxConcat)

+ (nonnull RxObservable *)concat {
    return [self merge:1];
}

@end

@implementation NSObject (RxMerge)

- (nonnull RxObservable *)merge {
    return [[RxMerge alloc] initWithSource:[self asObservable]];
}

- (nonnull RxObservable *)merge:(NSUInteger)maxConcurrent {
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

- (nonnull id)reduce:(nonnull id)start combine:(id(^)(id __nonnull initial, id __nonnull element))combine {
    id res = start;
    for (id o in self) {
        res = combine(res, o);
    }
    return res;
}

- (nonnull RxObservable *)amb {
    return [self reduce:[RxObservable never] combine:^RxObservable *(RxObservable *initial, RxObservable *element) {
        return [initial amb:[element asObservable]];
    }];
}

@end

@implementation NSObject (RxWithLatestFrom)

- (nonnull RxObservable *)withLatestFrom:(nonnull id <RxObservableConvertibleType>)second
                          resultSelector:(id __nonnull(^)(id __nonnull, id __nonnull))resultSelector {

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