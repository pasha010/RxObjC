//
//  RxDeallocatingObservable
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RxObjC/RxObjC.h>
#import "RxCocoa.h"

NS_ASSUME_NONNULL_BEGIN

#if !DISABLE_SWIZZLING

@interface RxDeallocatingObservable : NSObject <RxObservableConvertibleType, RxMessageSentObserver>

@property (assign, nonatomic, readwrite) IMP targetImplementation;
@property (assign, nonatomic, readonly) BOOL isActive;

@end

#endif

NS_ASSUME_NONNULL_END