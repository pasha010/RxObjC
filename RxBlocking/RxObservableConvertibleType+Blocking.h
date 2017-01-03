//
//  RxObservableConvertibleType(Blocking)
//  RxObjC
// 
//  Created by Pavel Malkov on 13.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RxObjC/RxObjC.h>

@class RxBlockingObservable<E>;

NS_ASSUME_NONNULL_BEGIN

@interface RxObservable<E> (Blocking)
/**
 * Converts an Observable into a `BlockingObservable` (an Observable with blocking operators).
 * @return: `BlockingObservable` version of `self`
 */
- (nonnull RxBlockingObservable<E> *)toBlocking;

@end

NS_ASSUME_NONNULL_END