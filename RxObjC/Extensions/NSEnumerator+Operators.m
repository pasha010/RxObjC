//
//  NSEnumerator(Operators)
//  RxObjC
// 
//  Created by Pavel Malkov on 16.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "NSEnumerator+Operators.h"

NSEnumeratorCombinePlus NSCombinePlus() {
    return ^NSNumber *(NSNumber *initial, NSNumber *element) {
        return @(initial.integerValue + element.integerValue);
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