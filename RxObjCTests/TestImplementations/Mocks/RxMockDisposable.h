//
//  RxMockDisposable
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxDisposable.h"

@class RxTestScheduler;

NS_ASSUME_NONNULL_BEGIN

@interface RxMockDisposable : NSObject <RxDisposable>

@property (nonnull, readonly) NSArray<NSNumber *> *ticks;

- (nonnull instancetype)initWithScheduler:(nonnull RxTestScheduler *)scheduler;

@end

NS_ASSUME_NONNULL_END