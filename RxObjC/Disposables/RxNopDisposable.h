//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxDisposable.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxNopDisposable : NSObject <RxDisposable>
+ (instancetype)sharedInstance;
@end

NS_ASSUME_NONNULL_END