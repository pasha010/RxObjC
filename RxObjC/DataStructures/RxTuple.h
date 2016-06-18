//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObjC.h"

NS_ASSUME_NONNULL_BEGIN

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
 * A tuple is an ordered collection of objects. It may contain nils, represented
 * by RxTupleNil.
 */
@interface RxTuple : NSObject <NSCoding, NSCopying, NSFastEnumeration>

/// The number of objects in the tuple, including any nil values.
@property (nonatomic, readonly) NSUInteger count;

/// An array of all the objects in the tuple.
///
/// RxTupleNils are converted to NSNulls in the array.
@property (nonnull, nonatomic, copy, readonly) NSArray<id> *array;

/// Invokes +tupleWithArray:convertNullsToNils: with `convert` set to NO.
+ (nonnull instancetype)tupleWithArray:(nullable NSArray<id> *)array;

/// Creates a new tuple out of the given array.
///
/// convert - Whether to convert `NSNull` objects in the array to `RxTupleNil`
///           values for the tuple. If this is NO, `NSNull`s will be left
///           untouched.
+ (nonnull instancetype)tupleWithArray:(nullable NSArray<id> *)array convertNullsToNils:(BOOL)convert;

/// Creates a new tuple with the given objects.
///
/// To include nil objects in the tuple, use `RxTupleNil` in the argument list.
+ (nonnull instancetype)tupleWithObjects:(nullable id)object, ... NS_REQUIRES_NIL_TERMINATION;


- (nullable id)objectAtIndex:(NSUInteger)index;
@end

@interface RxTuple (ObjectSubscripting)

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

NS_ASSUME_NONNULL_END