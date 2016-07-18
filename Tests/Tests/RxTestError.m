//
//  RxTestError
//  RxObjC
// 
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTestError.h"


@implementation RxTestError

+ (nonnull instancetype)testError {
    static dispatch_once_t token;
    static RxTestError *instance;
    dispatch_once(&token, ^{
        instance = [RxTestError errorWithDomain:@"dummyError" code:-232 userInfo:nil];
    });
    return instance;
}

RxTestError *testError() {
    return [RxTestError testError];
}

+ (nonnull instancetype)testError1 {
    static dispatch_once_t token;
    static RxTestError *instance;
    dispatch_once(&token, ^{
        instance = [RxTestError errorWithDomain:@"dummyError1" code:-233 userInfo:nil];
    });
    return instance;
}

RxTestError *testError1() {
    return [RxTestError testError1];
}

+ (nonnull instancetype)testError2 {
    static dispatch_once_t token;
    static RxTestError *instance;
    dispatch_once(&token, ^{
        instance = [RxTestError errorWithDomain:@"dummyError2" code:-234 userInfo:nil];
    });
    return instance;
}

RxTestError *testError2() {
    return [RxTestError testError2];
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (!other || ![[other class] isEqual:[self class]]) {
        return NO;
    }
    return YES;
}


@end