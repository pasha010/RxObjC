//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxCancelable.h"

NS_ASSUME_NONNULL_BEGIN

/**
Represents a disposable resource that can be checked for disposal status.
*/
@interface RxBooleanDisposable : NSObject <RxCancelable>

- (nonnull instancetype)init;
- (nonnull instancetype)initWithDisposed:(BOOL)disposed NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END