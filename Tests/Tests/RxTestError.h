//
//  RxTestError
//  RxObjC
// 
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RxTestError : NSError

+ (nonnull instancetype)testError;
FOUNDATION_EXTERN RxTestError *testError();

+ (nonnull instancetype)testError1;
FOUNDATION_EXTERN RxTestError *testError1();

+ (nonnull instancetype)testError2;
FOUNDATION_EXTERN RxTestError *testError2();

@end

NS_ASSUME_NONNULL_END