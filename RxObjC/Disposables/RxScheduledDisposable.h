//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxCancelable.h"

NS_ASSUME_NONNULL_BEGIN

/**
Represents a disposable resource whose disposal invocation will be scheduled on the specified scheduler.
*/
@interface RxScheduledDisposable : NSObject <RxCancelable>
@end

NS_ASSUME_NONNULL_END