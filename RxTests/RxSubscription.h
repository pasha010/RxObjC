//
//  RxSubscription
//  RxObjC
// 
//  Created by Pavel Malkov on 21.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
Records information about subscriptions to and unsubscriptions from observable sequences.
*/
@interface RxSubscription : NSObject

/**
 Subscription virtual time.
*/
@property (assign, readonly) NSUInteger subscribe;

/**
 Unsubscription virtual time.
*/
@property (assign, readonly) NSUInteger unsubscribe;

/**
 Creates a new subscription object with the given virtual subscription time.

 - parameter subscribe: Virtual time at which the subscription occurred.
*/
- (nonnull instancetype)initWithSubsribe:(NSUInteger)subscribe;

/**
 Creates a new subscription object with the given virtual subscription and unsubscription time.

 - parameter subscribe: Virtual time at which the subscription occurred.
 - parameter unsubscribe: Virtual time at which the unsubscription occurred.
*/
- (nonnull instancetype)initWithSubscribe:(NSUInteger)subscribe unsubscribe:(NSUInteger)unsubscribe;


@end

NS_ASSUME_NONNULL_END