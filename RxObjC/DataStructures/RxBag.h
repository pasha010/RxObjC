//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObserverType.h"
#import "RxDisposable.h"

@class RxTuple;

static int const RxBagArrayDictionaryMaxSize = 20;

NS_ASSUME_NONNULL_BEGIN

/**
Class that enables using memory allocations as a means to uniquely identify objects.
*/
@interface RxIdentity : NSObject
@end

/**
Unique identifier for object added to `Bag`.
*/
@interface RxBagKey : NSObject <NSCopying>
@property (nullable, strong, nonatomic) RxIdentity *uniqueIdentity;
@property (assign, nonatomic) NSInteger key;
@end

typedef NSInteger RxScopeUniqueTokenType;

/**
Data structure that represents a bag of elements typed `T`.

Single element can be stored multiple times.

Time and space complexity of insertion an deletion is O(n).

It is suitable for storing small number of elements.
*/
@interface RxBag<T> : NSObject {
@package
    RxIdentity *__nullable _uniqueIdentity;
    RxScopeUniqueTokenType _nextKey;
    RxBagKey *__nullable _key0;
    T __nullable _value0;
    RxBagKey *__nullable _key1;
    T __nullable _value1;
    NSMutableArray<RxTuple *> *__nonnull _pairs;
    NSMutableDictionary<RxBagKey *, T> *__nullable _dictionary;
    BOOL _onlyFastPath;
}

- (nonnull instancetype)init;

/**
Inserts `value` into bag.

- parameter element: Element to insert.
- returns: Key that can be used to remove element from bag.
*/
- (nonnull RxBagKey *)insert:(nonnull T)element;

/**
- returns: Number of elements in bag.
*/
- (NSUInteger)count;

/**
Removes all elements from bag and clears capacity.
*/
- (void)removeAll;

/**
Removes element with a specific `key` from bag.

- parameter key: Key that identifies element to remove from bag.
- returns: Element that bag contained, or nil in case element was already removed.
*/
- (nullable T)removeKey:(nonnull RxBagKey *)key;

@end

@interface RxBag (ForEach)
/**
Enumerates elements inside the bag.

- parameter action: Enumeration closure.
*/
- (void)forEach:(nonnull void(^)(id))action;
@end

@interface RxBag (Observer) <RxObserverType>

- (void)on:(nonnull RxEvent<id> *)event;

@end

FOUNDATION_EXTERN void rx_disposeAllInBag(RxBag<id <RxDisposable>> *bag);

NS_ASSUME_NONNULL_END