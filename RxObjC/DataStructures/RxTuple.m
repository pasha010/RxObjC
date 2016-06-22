//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTuple.h"

@implementation RxTupleNil

+ (nonnull instancetype)tupleNil {
    static dispatch_once_t onceToken;
    static RxTupleNil *tupleNil = nil;

    dispatch_once(&onceToken, ^{
        tupleNil = [[self alloc] init];
    });

    return tupleNil;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder {
    // Always return the singleton.
    return self.class.tupleNil;
}

- (void)encodeWithCoder:(NSCoder *)coder {
}
@end

@interface RxTuple ()
@property (nonatomic, strong) NSArray<id> *backingArray;
@end

@implementation RxTuple

#pragma mark Properties

- (NSArray<id> *)array {
    NSMutableArray<id> *newArray = [NSMutableArray arrayWithCapacity:self.backingArray.count];
    for (id object in self.backingArray) {
        [newArray addObject:(object == RxTupleNil.tupleNil ? NSNull.null : object)];
    }

    return newArray;
}

- (NSUInteger)count {
    return self.backingArray.count;
}

#pragma mark Lifecycle

+ (nonnull instancetype)tupleWithArray:(nullable NSArray<id> *)array {
    return [self tupleWithArray:array convertNullsToNils:NO];
}

+ (nonnull instancetype)tupleWithArray:(nullable NSArray<id> *)array convertNullsToNils:(BOOL)convert {
    RxTuple *tuple = [[self alloc] init];

    if (convert) {
        NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:array.count];
        for (id object in array) {
            [newArray addObject:(object == NSNull.null ? RxTupleNil.tupleNil : object)];
        }
        tuple.backingArray = newArray;
    } else {
        tuple.backingArray = [array copy];
    }

    return tuple;
}

+ (nonnull instancetype)tupleWithObjects:(nullable id)object, ... {
    RxTuple *tuple = [[self alloc] init];

    va_list args;
    va_start(args, object);

    NSUInteger count = 0;
    for (id currentObject = object; currentObject != nil; currentObject = va_arg(args, id)) {
        ++count;
    }

    va_end(args);

    if (count == 0) {
        tuple.backingArray = @[];
        return tuple;
    }

    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:count];

    va_start(args, object);
    for (id currentObject = object; currentObject != nil; currentObject = va_arg(args, id)) {
        [objects addObject:currentObject];
    }

    va_end(args);

    tuple.backingArray = objects;
    return tuple;
}

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _backingArray = [NSArray array];
    }
    return self;
}

#pragma mark NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> %@", self.class, self, self.array];
}

- (BOOL)isEqual:(RxTuple *)object {
    if (object == self) {
        return YES;
    }
    if (![object isKindOfClass:self.class]) {
        return NO;
    }

    return [self.backingArray isEqual:object.backingArray];
}

- (NSUInteger)hash {
    return self.backingArray.hash;
}

#pragma mark NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
    return [self.backingArray countByEnumeratingWithState:state objects:buffer count:len];
}

#pragma mark NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    // we're immutable, bitches!
    return self;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    if (self) {
        _backingArray = [coder decodeObjectForKey:@keypath(self.backingArray)];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    if (self.backingArray) {
        [coder encodeObject:self.backingArray forKey:@keypath(self.backingArray)];
    }
}

#pragma mark Indexing

- (nullable id)objectAtIndex:(NSUInteger)index {
    if (index >= self.count) {
        return nil;
    }

    id object = self.backingArray[index];
    return (object == RxTupleNil.tupleNil ? nil : object);
}

@end

@implementation RxTuple (ObjectSubscripting)

- (nullable id)objectAtIndexedSubscript:(NSUInteger)idx {
    return [self objectAtIndex:idx];
}

@end

@implementation RxTupleUnpackingTrampoline

#pragma mark Lifecycle

+ (instancetype)trampoline {
    static dispatch_once_t onceToken;
    static id trampoline = nil;
    dispatch_once(&onceToken, ^{
        trampoline = [[self alloc] init];
    });

    return trampoline;
}

- (void)setObject:(RxTuple *)tuple forKeyedSubscript:(NSArray *)variables {
    NSCParameterAssert(variables != nil);

    [variables enumerateObjectsUsingBlock:^(NSValue *value, NSUInteger index, BOOL *stop) {
        __strong id *ptr = (__strong id *)value.pointerValue;
        *ptr = tuple[index];
    }];
}

@end