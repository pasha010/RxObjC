//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservableType.h"
#import "RxEvent.h"
#import "RxObservableBlockTypedef.h"

NS_ASSUME_NONNULL_BEGIN

/**
A type-erased `ObservableType`.

It represents a push style sequence.
*/
@interface RxObservable<__covariant Element> : NSObject <RxObservableType>

- (nonnull instancetype)init;

- (nonnull RxObservable *)_composeMap:(nonnull RxMapSelector)mapSelector;

@end

NS_ASSUME_NONNULL_END