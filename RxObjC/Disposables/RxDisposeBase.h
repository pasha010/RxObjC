//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObjCCommon.h"

NS_ASSUME_NONNULL_BEGIN

/**
Base class for all disposables.
*/
@interface RxDisposeBase : NSObject

- (nonnull instancetype)init;

@end

NS_ASSUME_NONNULL_END