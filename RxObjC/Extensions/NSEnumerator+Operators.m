//
//  NSEnumerator(Operators)
//  RxObjC
// 
//  Created by Pavel Malkov on 16.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "NSEnumerator+Operators.h"

NSEnumeratorCombinePlus RxCombinePlus() {
    static dispatch_once_t token;
    static NSEnumeratorCombinePlus combine = nil;
    dispatch_once(&token, ^{
        combine = ^NSNumber *(NSNumber *initial, NSNumber *element) {
            return @(initial.doubleValue + element.doubleValue);
        };
    });
    return [combine copy];
}

NSEnumeratorCombinePlus RxCombineDiff() {
    static dispatch_once_t token;
    static NSEnumeratorCombinePlus combine = nil;
    dispatch_once(&token, ^{
        combine = ^NSNumber *(NSNumber *initial, NSNumber *element) {
            return @(initial.doubleValue - element.doubleValue);
        };
    });
    return [combine copy];
}

NSEnumeratorCombinePlus RxCombineMult() {
    static dispatch_once_t token;
    static NSEnumeratorCombinePlus combine = nil;
    dispatch_once(&token, ^{
        combine = ^NSNumber *(NSNumber *initial, NSNumber *element) {
            return @(initial.doubleValue * element.doubleValue);
        };
    });
    return [combine copy];
}

NSEnumeratorCombinePlus RxCombineDiv() {
    static dispatch_once_t token;
    static NSEnumeratorCombinePlus combine = nil;
    dispatch_once(&token, ^{
        combine = ^NSNumber *(NSNumber *initial, NSNumber *element) {
            return @(initial.doubleValue / element.doubleValue);
        };
    });
    return [combine copy];
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