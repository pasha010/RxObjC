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


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
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

#pragma clang diagnostic pop