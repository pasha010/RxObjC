//
//  NSObject+RxObjC_Dealloc.h
//  NSObject+RxObjC_Dealloc
//
//  Created by Pavel Malkov on 25.08.17.
//  Copyright © 2017 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RxObservable<E>;

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (RxObjC_Dealloc)

/**
 * Observable sequence of object deallocated events.
 * After object is deallocated one `()` element will be produced and sequence will immediately complete.
 * @return Observable sequence of object deallocated events.
 */
@property (nonnull, strong, readonly) RxObservable<id> *rx_deallocated;

@end

NS_ASSUME_NONNULL_END