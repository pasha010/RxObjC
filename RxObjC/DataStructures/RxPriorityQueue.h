//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RxPriorityQueue<ObjectType> : NSObject

@property (assign, readonly) BOOL isEmpty;

- (nonnull instancetype)initWithHasHigherPriority:(BOOL(^)(ObjectType __nonnull, ObjectType __nonnull))hasHigherPriority;

- (void)enqueue:(nonnull ObjectType)element;

- (nullable ObjectType)peek;

- (nullable ObjectType)dequeue;

- (void)remove:(nonnull ObjectType)element;
@end

NS_ASSUME_NONNULL_END