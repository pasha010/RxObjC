//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxDisposeBase.h"
#import "RxCancelable.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^RxDisposeAction)();

/**
 * Represents an Action-based disposable.
 * When dispose method is called, disposal action will be dereferenced.
*/
@interface RxAnonymousDisposable : RxDisposeBase <RxCancelable>

/**
 * Constructs a new disposable with the given action used for disposal.
 * @param disposeAction - Disposal action which will be run upon calling `dispose`.
*/
- (nonnull instancetype)initWithDisposeAction:(nullable RxDisposeAction)disposeAction;

+ (nonnull instancetype)create:(nullable RxDisposeAction)disposeAction;

@end

NS_ASSUME_NONNULL_END