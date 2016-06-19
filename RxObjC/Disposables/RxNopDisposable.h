//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxDisposable.h"

NS_ASSUME_NONNULL_BEGIN

/**
Represents a disposable that does nothing on disposal.

Nop = No Operation
*/
@interface RxNopDisposable : NSObject <RxDisposable>

/**
Singleton instance of `NopDisposable`.
*/
+ (nonnull instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END