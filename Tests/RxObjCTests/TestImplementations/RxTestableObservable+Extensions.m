//
//  RxTestableObservable(Extensions)
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTestableObservable+Extensions.h"

@implementation RxObservable (RxEquals)

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    return !(!other || ![[other class] isEqual:[self class]]);
}

@end

@implementation RxTestableObservable (Extensions)

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    return !(!other || ![[other class] isEqual:[self class]]);

}


@end