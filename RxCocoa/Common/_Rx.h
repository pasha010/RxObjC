//
//  _Rx.h
//  RxCocoa
//
//  Created by Pavel Malkov on 18.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef RxCocoa_RxHeader_H
#define RxCocoa_RxHeader_H

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

/**
 * ################################################################################
 * This file is part of Rx private API
 * ################################################################################
 */

#if        TRACE_RESOURCES >= 2
#   define DLOG(...)         NSLog(__VA_ARGS__)
#else
#   define DLOG(...)
#endif

#if        DEBUG
#   define ABORT_IN_DEBUG    abort();
#else
#   define ABORT_IN_DEBUG
#endif


#define SEL_VALUE(x)      [NSValue valueWithPointer:(x)]
#define CLASS_VALUE(x)    [NSValue valueWithNonretainedObject:(x)]
#define IMP_VALUE(x)      [NSValue valueWithPointer:(x)]

// Inspired by http://p99.gforge.inria.fr

// https://gcc.gnu.org/onlinedocs/gcc-2.95.3/cpp_1.html#SEC26
#define Rx_CAT2(_1, _2) _Rx_CAT2(_1, _2)

#define Rx_ELEMENT_AT(n, ...) Rx_CAT2(_Rx_ELEMENT_AT_, n)(__VA_ARGS__)

#define Rx_COUNT(...) Rx_ELEMENT_AT(6, ## __VA_ARGS__, 6, 5, 4, 3, 2, 1, 0)

/**
 * #define JOIN(context, index, head, tail) head; tail
 * #define APPLY(context, index, item) item = (context)[index]
 *
 * Rx_FOR(A, JOIN, APPLY, toto, tutu);
 *
 * toto = (A)[0]; tutu = (A)[1];
 */
#define Rx_FOR(context, join, generate, ...) Rx_CAT2( _Rx_FOR_, Rx_COUNT(__VA_ARGS__))(context, 0, join, generate, ## __VA_ARGS__)

/**
 * #define JOIN(context, index, head, tail) head tail
 * #define APPLY(context, index, item) item = (context)[index]
 *
 * Rx_FOR(A, JOIN, APPLY, toto, tutu);
 *
 * , toto = (A)[0], tutu = (A)[1]
 */
#define Rx_FOR_COMMA(context, generate, ...) Rx_CAT2( _Rx_FOR_COMMA_, Rx_COUNT(__VA_ARGS__))(context, 0, generate, ## __VA_ARGS__)

#define Rx_INC(x) Rx_CAT2(_Rx_INC_, x)

// element at

#define _Rx_ELEMENT_AT_0(x, ...) x
#define _Rx_ELEMENT_AT_1(_0, x, ...) x
#define _Rx_ELEMENT_AT_2(_0, _1, x, ...) x
#define _Rx_ELEMENT_AT_3(_0, _1, _2, x, ...) x
#define _Rx_ELEMENT_AT_4(_0, _1, _2, _3, x, ...) x
#define _Rx_ELEMENT_AT_5(_0, _1, _2, _3, _4, x, ...) x
#define _Rx_ELEMENT_AT_6(_0, _1, _2, _3, _4, _5, x, ...) x

// rx for

#define _Rx_FOR_0(context, index, join, generate)

#define _Rx_FOR_1(context, index, join, generate, head) \
generate(context, index, head)

#define _Rx_FOR_2(context, index, join, generate, head, ...) \
join(context, index, generate(context, index, head), _Rx_FOR_1(context, Rx_INC(index), join, generate, __VA_ARGS__))

#define _Rx_FOR_3(context, index, join, generate, head, ...) \
join(context, index, generate(context, index, head), _Rx_FOR_2(context, Rx_INC(index), join, generate, __VA_ARGS__))

#define _Rx_FOR_4(context, index, join, generate, head, ...) \
join(context, index, generate(context, index, head), _Rx_FOR_3(context, Rx_INC(index), join, generate, __VA_ARGS__))

#define _Rx_FOR_5(context, index, join, generate, head, ...) \
join(context, index, generate(context, index, head), _Rx_FOR_4(context, Rx_INC(index), join, generate, __VA_ARGS__))

#define _Rx_FOR_6(context, index, join, generate, head, ...) \
join(context, index, generate(context, index, head), _Rx_FOR_5(context, Rx_INC(index), join, generate, __VA_ARGS__))

// rx for

#define _Rx_FOR_COMMA_0(context, index, generate)

#define _Rx_FOR_COMMA_1(context, index, generate, head) \
, generate(context, index, head)

#define _Rx_FOR_COMMA_2(context, index, generate, head, ...) \
, generate(context, index, head) _Rx_FOR_COMMA_1(context, Rx_INC(index), generate, __VA_ARGS__)

#define _Rx_FOR_COMMA_3(context, index, generate, head, ...) \
, generate(context, index, head) _Rx_FOR_COMMA_2(context, Rx_INC(index), generate, __VA_ARGS__)

#define _Rx_FOR_COMMA_4(context, index, generate, head, ...) \
, generate(context, index, head) _Rx_FOR_COMMA_3(context, Rx_INC(index), generate, __VA_ARGS__)

#define _Rx_FOR_COMMA_5(context, index, generate, head, ...) \
, generate(context, index, head) _Rx_FOR_COMMA_4(context, Rx_INC(index), generate, __VA_ARGS__)

#define _Rx_FOR_COMMA_6(context, index, generate, head, ...) \
, generate(context, index, head) _Rx_FOR_COMMA_5(context, Rx_INC(index), generate, __VA_ARGS__)


// rx inc

#define _Rx_INC_0   1
#define _Rx_INC_1   2
#define _Rx_INC_2   3
#define _Rx_INC_3   4
#define _Rx_INC_4   5
#define _Rx_INC_5   6
#define _Rx_INC_6   7

// rx cat

#define _Rx_CAT2(_1, _2) _1 ## _2

#endif // RxCocoa_RxHeader_H

