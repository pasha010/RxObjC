 //
//  RxObjC.m
//  RxObjC
//
//  Created by Pavel Malkov on 18.06.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//
#import "RxObjC.h"
#import "RxError.h"

 void rx_abstractMethod() {
    rx_fatalMessage(@"Abstract method");
}

void rx_fatalMessage(NSString *message) {
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
    if (*i == NSIntegerMax) {
        @throw [RxError overflow];
    }
    NSInteger result = *i;
    *i = *i - 1;
    return result;
}



