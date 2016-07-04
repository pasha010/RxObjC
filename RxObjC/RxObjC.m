 //
//  RxObjC.m
//  RxObjC
//
//  Created by Pavel Malkov on 18.06.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//
#import "RxObjC.h"
#import "RxError.h"

id rx_abstractMethod() {
    rx_fatalError(@"Abstract method");
    return nil;
}

void rx_fatalError(NSString *message) {
    assert(NO && [message cStringUsingEncoding:NSUTF8StringEncoding]);
}

NSInteger rx_incrementChecked(NSInteger *i) {
    if (*i == NSIntegerMax) {
        @throw [RxError overflow];
    }
    NSInteger result = *i;
    *i = *i + 1;
    return result;
}

 NSInteger rx_decrementChecked(NSInteger *i) {
    if (*i == NSIntegerMin) {
        @throw [RxError overflow];
    }
    NSInteger result = *i;
    *i = *i - 1;
    return result;
}

NSUInteger rx_incrementCheckedUnsigned(NSUInteger *i) {
    if (*i == NSUIntegerMax) {
        @throw [RxError overflow];
    }
    NSUInteger result = *i;
    *i = *i + 1;
    return result;
}

NSUInteger rx_decrementCheckedUnsigned(NSUInteger *i) {
    if (*i == 0) {
        @throw [RxError overflow];
    }
    NSUInteger result = *i;
    *i = *i - 1;
    return result;
}


