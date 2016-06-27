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

#pragma clang diagnostic pop