//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RxDisposable;

NS_ASSUME_NONNULL_BEGIN

@interface RxStableCompositeDisposable : NSObject

+ (nonnull id <RxDisposable>)createDisposable1:(nonnull id <RxDisposable>)disposable1
                                   disposable2:(nonnull id <RxDisposable>)disposable2;

@end

NS_ASSUME_NONNULL_END