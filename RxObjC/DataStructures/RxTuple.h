//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObjCCommon.h"

NS_ASSUME_NONNULL_BEGIN

/// Creates a new tuple with the given values. At least one value must be given.
/// Values can be nil.
#define RxTuplePack(...) \
    RxTuplePack_(__VA_ARGS__)

/// Declares new object variables and unpacks a RxTuple into them.
///
/// This macro should be used on the left side of an assignment, with the
/// tuple on the right side. Nothing else should appear on the same line, and the
/// macro should not be the only statement in a conditional or loop body.
///
/// If the tuple has more values than there are variables listed, the excess
/// values are ignored.
///
/// If the tuple has fewer values than there are variables listed, the excess
/// variables are initialized to nil.
///
/// Examples
///
///   RxTupleUnpack(NSString *string, NSNumber *num) = [RxTuple tupleWithObjects:@"foo", @5, nil];
///   NSLog(@"string: %@", string);
///   NSLog(@"num: %@", num);
///
///   /* The above is equivalent to: */
///   RxTuple *t = [RxTuple tupleWithObjects:@"foo", @5, nil];
///   NSString *string = t[0];
///   NSNumber *num = t[1];
///   NSLog(@"string: %@", string);
///   NSLog(@"num: %@", num);
#define RxTupleUnpack(...) \
        RxTupleUnpack_(__VA_ARGS__)

/// A sentinel object that represents nils in the tuple.
///
/// It should never be necessary to create a tuple nil yourself. Just use
/// +tupleNil.
@interface RxTupleNil : NSObject <NSCopying, NSCoding>
/// A singleton instance.
+ (nonnull instancetype)tupleNil;
@end

/**
 * @see RACTuple in ReactiveCocoa 2.5 version (Thanks!)
 * A tuple is an ordered collection of objects. It may contain nils, represented by RxNil.
 */
@interface RxTuple2<E1, E2> : NSObject <NSCoding, NSCopying, NSFastEnumeration>

@property (nullable, nonatomic, readonly) E1 first;
@property (nullable, nonatomic, readonly) E2 second;

/** The number of objects in the tuple, including any nil values. */
@property (nonatomic, readonly) NSUInteger count;

/**
 * An array of all the objects in the tuple.
 * RxNils are converted to NSNulls in the array.
 */
@property (nonnull, nonatomic, copy, readonly) NSArray<id> *array;

+ (nonnull instancetype)create:(nonnull E1)first and:(nonnull E2)second;

/**
 * Invokes +tupleWithArray:convertNullsToNils: with `convert` set to NO.
 */
+ (nonnull instancetype)tupleWithArray:(nullable NSArray<id> *)array;

/**
 * Creates a new tuple out of the given array.
 * @param convert Whether to convert `NSNull` objects in the array to `RxNil` alues for the tuple. If this is NO, `NSNull`s will be left untouched.
 */
+ (nonnull instancetype)tupleWithArray:(nullable NSArray<id> *)array convertNullsToNils:(BOOL)convert;

- (nullable id)objectAtIndex:(NSUInteger)index;

@end

@interface RxTuple3<E1, E2, E3> : RxTuple2<E1, E2>
@property (nullable, nonatomic, readonly) E3 third;

+ (nonnull instancetype)create:(nonnull E1)first and:(nonnull E2)second and:(nonnull E3)third;

@end

@interface RxTuple4<E1, E2, E3, E4> : RxTuple3<E1, E2, E3>
@property (nullable, nonatomic, readonly) E4 fourth;

+ (nonnull instancetype)create:(nonnull E1)o1 and:(nonnull E2)o2 and:(nonnull E3)o3 and:(nonnull E4)fourth;

@end

@interface RxTuple5<E1, E2, E3, E4, E5> : RxTuple4<E1, E2, E3, E4>
@property (nullable, nonatomic, readonly) E5 fifth;

+ (nonnull instancetype)create:(nonnull E1)first and:(nonnull E2)second and:(nonnull E3)third and:(nonnull E4)fourth and:(nonnull E5)fifth;

@end

@interface RxTuple6<E1, E2, E3, E4, E5, E6> : RxTuple5<E1, E2, E3, E4, E5>
@property (nullable, nonatomic, readonly) E6 sixth;

+ (nonnull instancetype)create:(nonnull E1)first and:(nonnull E2)second and:(nonnull E3)third and:(nonnull E4)fourth and:(nonnull E5)fifth and:(nonnull E6)sixth;

@end

@interface RxTuple7<E1, E2, E3, E4, E5, E6, E7> : RxTuple6<E1, E2, E3, E4, E5, E6>
@property (nullable, nonatomic, readonly) E7 seventh;

+ (nonnull instancetype)create:(nonnull E1)first and:(nonnull E2)second and:(nonnull E3)third and:(nonnull E4)fourth and:(nonnull E5)fifth and:(nonnull E6)sixth and:(nonnull E7)seventh;

@end

@interface RxTuple<E1, E2, E3, E4, E5, E6, E7, E8> : RxTuple7<E1, E2, E3, E4, E5, E6, E7>
@property (nullable, nonatomic, readonly) E8 eighth;

+ (nonnull instancetype)create:(nonnull E1)first and:(nonnull E2)second and:(nonnull E3)third and:(nonnull E4)fourth and:(nonnull E5)fifth and:(nonnull E6)sixth and:(nonnull E7)seventh and:(nonnull E8)eighth;

@end

@interface RxTuple2 (ObjectSubscripting)

/// Invokes -objectAtIndex: with the given index.
- (nullable id)objectAtIndexedSubscript:(NSUInteger)idx;

@end

#define RxTuplePack_(...) \
    ([RxTuple tupleWithArray:@[ metamacro_foreach(RxTuplePack_object_or_rxtuplenil,, __VA_ARGS__) ]])

#define RxTuplePack_object_or_rxtuplenil(INDEX, ARG) \
    (ARG) ?: RxTupleNil.tupleNil,

#define RxTupleUnpack_(...) \
    metamacro_foreach(RxTupleUnpack_decl,, __VA_ARGS__) \
    \
    int RxTupleUnpack_state = 0; \
    \
    RxTupleUnpack_after: \
        ; \
        metamacro_foreach(RxTupleUnpack_assign,, __VA_ARGS__) \
        if (RxTupleUnpack_state != 0) RxTupleUnpack_state = 2; \
        \
        while (RxTupleUnpack_state != 2) \
            if (RxTupleUnpack_state == 1) { \
                goto RxTupleUnpack_after; \
            } else \
                for (; RxTupleUnpack_state != 1; RxTupleUnpack_state = 1) \
                    [RxTupleUnpackingTrampoline trampoline][ @[ metamacro_foreach(RxTupleUnpack_value,, __VA_ARGS__) ] ]

#define RxTupleUnpack_state metamacro_concat(RxTupleUnpack_state, __LINE__)
#define RxTupleUnpack_after metamacro_concat(RxTupleUnpack_after, __LINE__)
#define RxTupleUnpack_loop metamacro_concat(RxTupleUnpack_loop, __LINE__)

#define RxTupleUnpack_decl_name(INDEX) \
    metamacro_concat(metamacro_concat(RxTupleUnpack, __LINE__), metamacro_concat(_var, INDEX))

#define RxTupleUnpack_decl(INDEX, ARG) \
    __strong id RxTupleUnpack_decl_name(INDEX);

#define RxTupleUnpack_assign(INDEX, ARG) \
    __strong ARG = RxTupleUnpack_decl_name(INDEX);

#define RxTupleUnpack_value(INDEX, ARG) \
    [NSValue valueWithPointer:&RxTupleUnpack_decl_name(INDEX)],

@interface RxTupleUnpackingTrampoline : NSObject

+ (instancetype)trampoline;
- (void)setObject:(RxTuple2 *)tuple forKeyedSubscript:(NSArray *)variables;

@end

NS_ASSUME_NONNULL_END