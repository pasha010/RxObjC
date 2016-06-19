//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxBag.h"
#import "RxTuple.h"

NSInteger rx_hash(NSInteger _x) {
    NSInteger x = _x;
    // TODO &* implementation?
    x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = ((x >> 16) ^ x);
    return x;
}

@implementation RxIdentity {
    int32_t _forceAllocation;
}
@end

@implementation RxBagKey

- (instancetype)initWithUniqueIdentity:(nullable RxIdentity *)identity andKey:(NSInteger)key {
    self = [super init];
    if (self) {
        _uniqueIdentity = identity;
        _key = key;
    }
    return self;
}

- (NSUInteger)hash {
    if (_uniqueIdentity) {
        return rx_hash(_key) ^ _uniqueIdentity.hash;
    }
    return [super hash];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end

/**
Compares two `BagKey`s.
*/
BOOL rx_compareBagKeys(RxBagKey *lhs, RxBagKey *rhs) {
    return lhs.key == rhs.key && lhs.uniqueIdentity == rhs.uniqueIdentity;
}

@implementation RxBag 

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _nextKey = 0;
        _pairs = [NSMutableArray array];
        _onlyFastPath = YES;
    }
    return self;
}

- (nonnull RxBagKey *)insert:(nonnull id)element {
    _nextKey = _nextKey + 1;
#if DEBUG
    _nextKey = _nextKey % 20;
#endif
    
    if (_nextKey == 0) {
        _uniqueIdentity = [[RxIdentity alloc] init];
    }

    RxBagKey *key = [[RxBagKey alloc] initWithUniqueIdentity:_uniqueIdentity andKey:_nextKey];

    if (!_key0) {
        _key0 = key;
        _value0 = element;
        return key;
    }

    _onlyFastPath = YES;

    if (!_key1) {
        _key1 = key;
        _value1 = element;
        return key;
    }

    if (_dictionary) {
        _dictionary[key] = element;
        return key;
    }

    if (_pairs.count < RxBagArrayDictionaryMaxSize) {
        [_pairs addObject:[RxTuple tupleWithArray:@[key, element]]];
        return key;
    }

    if (!_dictionary) {
        _dictionary = [NSMutableDictionary dictionary];
    }

    _dictionary[key] = element;

    return key;
}

- (NSUInteger)count {
    NSUInteger dictionaryCount = _dictionary.count;
    return _pairs.count + (_value0 != nil ? 1 : 0) + (_value1 != nil ? 1 : 0) + dictionaryCount;
}

- (void)removeAll {
    _key0 = nil;
    _value0 = nil;
    _key1 = nil;
    _value1 = nil;

    [_pairs removeAllObjects];
    [_dictionary removeAllObjects];
}

#pragma clang diagnostic push
#pragma ide diagnostic ignored "IncompatibleTypes"
- (nullable id)removeKey:(nonnull RxBagKey *)key {
    if (_key0 == key) {
        _key0 = nil;
        id value = _value0;
        _value0 = nil;
        return value;
    }

    if (_key1 == key) {
        _key1 = nil;
        id value = _value1;
        _value1 = nil;
        return value;
    }

    id existingObject = [_dictionary objectForKey:key];
    if (existingObject) {
        [_dictionary removeObjectForKey:key];
        return existingObject;
    }

    for (NSUInteger i = 0; i < _pairs.count; i++) {
        RxTuple *tuple = _pairs[i];
        if (tuple[0] == key) {
            id value = tuple[1];
            [_pairs removeObjectAtIndex:i];
            return value;
        }
    }

    return nil;
}
#pragma clang diagnostic pop

/**
A textual representation of `self`, suitable for debugging.
*/
- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%zd elements in Bag", [self count]];
}

@end

@implementation RxBag (ForEach)

#pragma clang diagnostic push
#pragma ide diagnostic ignored "IncompatibleTypes"
- (void)forEach:(nonnull void(^)(id))action {
    if (_onlyFastPath) {
        if (_value0) {
            action(_value0);
        }
        return;
    }

    if (_value0) {
        action(_value0);
    }

    if (_value1) {
        action(_value1);
    }

    for (RxTuple *tuple in _pairs) {
        id value = tuple[1];
        action(value);
    }

    if (_dictionary.count > 0) {
        for (id element in _dictionary.allValues) {
            action(element);
        }
    }
}
#pragma clang diagnostic pop

@end

@implementation RxBag (Observer)

/**
 Dispatches `event` to app observers contained inside bag.

 - parameter action: Enumeration closure.
 */
- (void)on:(nonnull RxEvent<id> *)event {
    if (_onlyFastPath) {
        if ([_value0 conformsToProtocol:@protocol(RxObserverType)]) {
            [_value0 on:event];
        }
        return;
    }
    
    if (_value0) {
        if ([_value0 conformsToProtocol:@protocol(RxObserverType)]) {
            [_value0 on:event];
        }
    }
    
    if (_value1) {
        if ([_value1 conformsToProtocol:@protocol(RxObserverType)]) {
            [_value1 on:event];
        }
    }
    
    for (RxTuple *tuple in _pairs) {
        id value = tuple[1];
        if ([value conformsToProtocol:@protocol(RxObserverType)]) {
            [value on:event];
        }
    }

    if (_dictionary.count > 0) {
        for (id element in _dictionary.allValues) {
            if ([element conformsToProtocol:@protocol(RxObserverType)]) {
                [element on:event];
            }
        }
    }
}

- (void)onNext:(nullable id)element {
    [self on:[RxEvent next:element]];
}

- (void)onCompleted {
    [self on:[RxEvent completed]];
}

- (void)onError:(nullable NSError *)error {
    [self on:[RxEvent error:error]];
}

@end

#pragma clang diagnostic push
#pragma ide diagnostic ignored "IncompatibleTypes"
void rx_disposeAllInBag(RxBag<id <RxDisposable>> *bag) {
    if (!bag) {
        return;
    }

    if (bag->_onlyFastPath) {
        if ([bag->_value0 conformsToProtocol:@protocol(RxDisposable)]) {
            id <RxDisposable> value0 = bag->_value0;
            [value0 dispose];
        }
    }

    NSMutableArray<RxTuple *> *pairs = bag->_pairs;
    id <RxDisposable> value0 = bag->_value0;
    id <RxDisposable> value1 = bag->_value1;
    NSMutableDictionary<RxBagKey *, id <RxDisposable>> *dictionary = bag->_dictionary;
    
    if ([value0 conformsToProtocol:@protocol(RxDisposable)]) {
        [value0 dispose];
    }
    
    if ([value1 conformsToProtocol:@protocol(RxDisposable)]) {
        [value1 dispose];
    }
    
    for (RxTuple *tuple in pairs) {
        id value = tuple[1];
        if ([value conformsToProtocol:@protocol(RxDisposable)]) {
            [value dispose];
        }
    }

    if (dictionary.count > 0) {
        for (id element in dictionary.allValues) {
            if ([element conformsToProtocol:@protocol(RxDisposable)]) {
                [element dispose];
            }
        }
    }
}
#pragma clang diagnostic pop