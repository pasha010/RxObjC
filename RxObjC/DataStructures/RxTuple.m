//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTuple.h"

@interface RxTuple2 ()
@property (nonatomic, strong) NSArray<id> *backingArray;

- (instancetype)initWithArray:(NSArray *)array;
@end

@implementation RxTuple2

#pragma mark Properties

- (NSArray<id> *)array {
    NSMutableArray<id> *newArray = [NSMutableArray arrayWithCapacity:self.backingArray.count];
    for (id object in self.backingArray) {
        [newArray addObject:(object == [RxNil null] ? NSNull.null : object)];
    }

    return newArray;
}

- (NSUInteger)count {
    return self.backingArray.count;
}

- (id)first {
    return self[0];
}

- (id)second {
    return self[1];
}

#pragma mark Lifecycle

+ (nonnull instancetype)create:(nonnull id)first and:(nonnull id)second {
    return [[self alloc] initWithArray:@[first ?: [RxNil null], second ?: [RxNil null]]];
}

+ (nonnull instancetype)tupleWithArray:(nullable NSArray<id> *)array {
    return [self tupleWithArray:array convertNullsToNils:NO];
}

+ (nonnull instancetype)tupleWithArray:(nullable NSArray<id> *)array convertNullsToNils:(BOOL)convert {
    NSArray *backingArray = [array copy];
    if (convert) {
        NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:array.count];
        for (id object in array) {
            [newArray addObject:(object == NSNull.null ? [RxNil null] : object)];
        }
        backingArray = [newArray copy];
    }

    return [[self alloc] initWithArray:backingArray];
}

- (nonnull instancetype)initWithArray:(nonnull NSArray *)array {
    self = [super init];
    if (self) {
        _backingArray = array;
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
        _backingArray = [coder decodeObjectForKey:@"backingArray"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    if (self.backingArray) {
        [coder encodeObject:self.backingArray forKey:@"backingArray"];
    }
}

#pragma mark Indexing

- (nullable id)objectAtIndex:(NSUInteger)index {
    if (index >= self.count) {
        return nil;
    }

    id object = self.backingArray[index];
    return (object == [RxNil null] ? nil : object);
}

@end

@implementation RxTuple2 (ObjectSubscripting)

- (nullable id)objectAtIndexedSubscript:(NSUInteger)idx {
    return [self objectAtIndex:idx];
}

@end

@implementation RxTuple3

- (id)third {
    return self[2];
}

+ (instancetype)create:(id)first and:(id)second and:(id)third {
    return [[self alloc] initWithArray:@[first ?: [RxNil null], second ?: [RxNil null], third ?: [RxNil null]]];
}

@end
@implementation RxTuple4

+ (instancetype)create:(id)o1 and:(id)o2 and:(id)o3 and:(id)o4 {
    return [[self alloc] initWithArray:@[o1 ?: [RxNil null], o2 ?: [RxNil null], o3 ?: [RxNil null], o4 ?: [RxNil null]]];
}

- (id)fourth {
    return self[3];
}

@end
@implementation RxTuple5

+ (instancetype)create:(id)o1 and:(id)o2 and:(id)o3 and:(id)o4 and:(id)o5 {
    return [[self alloc] initWithArray:@[o1 ?: [RxNil null], o2 ?: [RxNil null], o3 ?: [RxNil null], o4 ?: [RxNil null], o5 ?: [RxNil null]]];
}

- (id)fifth {
    return self[4];
}

@end
@implementation RxTuple6

+ (instancetype)create:(id)o1 and:(id)o2 and:(id)o3 and:(id)o4 and:(id)o5 and:(id)o6 {
    return [[self alloc] initWithArray:@[o1 ?: [RxNil null], o2 ?: [RxNil null], o3 ?: [RxNil null], o4 ?: [RxNil null], o5 ?: [RxNil null], o6 ?: [RxNil null]]];
}

- (id)sixth {
    return self[5];
}

@end
@implementation RxTuple7

+ (instancetype)create:(id)o1 and:(id)o2 and:(id)o3 and:(id)o4 and:(id)o5 and:(id)o6 and:(id)o7 {
    return [[self alloc] initWithArray:@[o1 ?: [RxNil null], o2 ?: [RxNil null], o3 ?: [RxNil null], o4 ?: [RxNil null], o5 ?: [RxNil null], o6 ?: [RxNil null], o7 ?: [RxNil null]]];
}

- (id)seventh {
    return self[6];
}

@end

@implementation RxTuple

+ (instancetype)create:(id)o1 and:(id)o2 and:(id)o3 and:(id)o4 and:(id)o5 and:(id)o6 and:(id)o7 and:(id)o8 {
    return [[self alloc] initWithArray:@[o1 ?: [RxNil null], o2 ?: [RxNil null], o3 ?: [RxNil null], o4 ?: [RxNil null], o5 ?: [RxNil null], o6 ?: [RxNil null], o7 ?: [RxNil null], o8 ?: [RxNil null]]];
}

- (id)eighth {
    return self[6];
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