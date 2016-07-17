//
//  NSEnumerator(Operators)
//  RxObjC
// 
//  Created by Pavel Malkov on 16.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "NSEnumerator+Operators.h"

RxEnumeratorCombineOperator RxCombinePlus() {
    static dispatch_once_t token;
    static RxEnumeratorCombineOperator combine = nil;
    dispatch_once(&token, ^{
        combine = ^NSNumber *(NSNumber *initial, NSNumber *element) {
            return @(initial.doubleValue + element.doubleValue);
        };
    });
    return [combine copy];
}

RxEnumeratorCombineOperator RxCombineDiff() {
    static dispatch_once_t token;
    static RxEnumeratorCombineOperator combine = nil;
    dispatch_once(&token, ^{
        combine = ^NSNumber *(NSNumber *initial, NSNumber *element) {
            return @(initial.doubleValue - element.doubleValue);
        };
    });
    return [combine copy];
}

RxEnumeratorCombineOperator RxCombineMult() {
    static dispatch_once_t token;
    static RxEnumeratorCombineOperator combine = nil;
    dispatch_once(&token, ^{
        combine = ^NSNumber *(NSNumber *initial, NSNumber *element) {
            return @(initial.doubleValue * element.doubleValue);
        };
    });
    return [combine copy];
}

RxEnumeratorCombineOperator RxCombineDiv() {
    static dispatch_once_t token;
    static RxEnumeratorCombineOperator combine = nil;
    dispatch_once(&token, ^{
        combine = ^NSNumber *(NSNumber *initial, NSNumber *element) {
            return @(initial.doubleValue / element.doubleValue);
        };
    });
    return [combine copy];
}

RxMapSelector RxReturnSelf() {
    return ^id(id e) {
        return e;
    };
}

@implementation NSEnumerator (Combine)

- (nonnull id)reduce:(nonnull id)start combine:(id(^)(id __nonnull initial, id __nonnull element))combine {
    id res = start;
    for (id o in self) {
        res = combine(res, o);
    }
    return res;
}

@end