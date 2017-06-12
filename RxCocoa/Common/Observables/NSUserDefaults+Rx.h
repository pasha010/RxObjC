//
//  NSUserDefaults(Rx)
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RxObjC/RxObjC.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSUserDefaults (Rx)

/**
 * current implementation is bad
 * not use this method
 * @param key
 * @return
 */
- (nonnull RxObservable *)rx_observeKey:(nullable NSString *)key __deprecated;

@end

NS_ASSUME_NONNULL_END