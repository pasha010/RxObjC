//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxNopDisposable.h"


@implementation RxNopDisposable

+ (instancetype)sharedInstance {
    static dispatch_once_t token = nil;
    static RxNopDisposable *nopDisposable = nil;
    dispatch_once(&token, ^{
        nopDisposable = [[RxNopDisposable alloc] init];
    });
    return nopDisposable;
}

/**
 * Does nothing.
 */
- (void)dispose {

}


@end