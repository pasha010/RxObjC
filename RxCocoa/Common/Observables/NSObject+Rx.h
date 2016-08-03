//
//  NSObject(Rx)
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RxObjC/RxObjC.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (RxDealloc)
/**
 * Observable sequence of object deallocated events.
 * After object is deallocated one `()` element will be produced and sequence will immediately complete.
 * @return: Observable sequence of object deallocated events.
 */
- (nonnull RxObservable *)rx_deallocated;

@end

NS_ASSUME_NONNULL_END