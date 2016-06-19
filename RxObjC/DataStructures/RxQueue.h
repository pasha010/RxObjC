//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RxQueue<ObjectType> : NSObject <NSFastEnumeration>

/**
- returns: Is queue empty.
*/
@property (assign, nonatomic, readonly) BOOL isEmpty;

/**
- returns: Number of elements inside queue.
*/
@property (assign, nonatomic, readonly) NSUInteger count;

/**
 * workaround Swift Generarators
 * @return array with generator alghorithm
 */
@property (nonnull, nonatomic, readonly) NSArray<ObjectType> *array;

- (nonnull instancetype)init;

/**
Creates new queue.

- parameter capacity: Capacity of newly created queue.
*/
- (nonnull instancetype)initWithCapacity:(NSUInteger)capacity NS_DESIGNATED_INITIALIZER;

/**
- returns: Element in front of a list of elements to `dequeue`.
*/
- (nullable ObjectType)peek;

/**
Enqueues `element`.

- parameter element: Element to enqueue.
*/
- (void)enqueue:(nonnull ObjectType)element;

/**
Dequeues element or throws an exception in case queue is empty.

- returns: Dequeued element.
*/
- (nullable ObjectType)dequeue;

@end

NS_ASSUME_NONNULL_END