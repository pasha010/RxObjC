//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxQueue.h"
#import <libextobjc/extobjc.h>

@implementation RxQueue {
    NSMutableArray *__nonnull _storage;
    NSUInteger _initialCapacity;
    NSUInteger _resizeFactor;
    NSUInteger _pushNextIndex;
    NSUInteger _count;
}

- (nonnull instancetype)init {
    return [self initWithCapacity:0];
}

- (nonnull instancetype)initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    if (self) {
        _count = 0;
        _resizeFactor = 2;
        _pushNextIndex = 0;
        _initialCapacity = capacity;
        _storage = [NSMutableArray arrayWithCapacity:capacity];
        for (NSUInteger i = 0; i < capacity; i++) {
            [_storage addObject:[EXTNil null]];
        }
    }
    return self;
}

- (NSUInteger)dequeueIndex {
    NSInteger index = _pushNextIndex - _count;
    return index < 0 ? index + _storage.count
                     : (NSUInteger) index;
}

- (BOOL)isEmpty {
    return _storage.count == 0;
}

- (NSUInteger)count {
    return _count;
}

- (nullable id)peek {
    return _storage[self.dequeueIndex];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained[])buffer count:(NSUInteger)len {
    return [_storage countByEnumeratingWithState:state objects:buffer count:len];
}

- (void)resizeTo:(NSUInteger)size {
    NSMutableArray<id> *newStorage = [NSMutableArray arrayWithCapacity:size];
    for (NSUInteger i = 0; i < size; i++) {
        [newStorage addObject:[EXTNil null]];
    }

    NSUInteger count = _count;

    NSUInteger dequeueIndex = self.dequeueIndex;
    NSUInteger spaceToEndOfQueue = _storage.count - dequeueIndex;

    // first batch is from dequeue index to end of array
    NSUInteger countElementsInFirstBatch = MIN(count, spaceToEndOfQueue);
    // second batch is wrapped from start of array to end of queue
    NSUInteger numberOfElementsInSecondBatch = count - countElementsInFirstBatch;

    for (NSUInteger i = 0, dequeueIndexIt = dequeueIndex;
         i < countElementsInFirstBatch && dequeueIndexIt < (dequeueIndex + countElementsInFirstBatch);
         i++, dequeueIndexIt++) {
        newStorage[i] = _storage[dequeueIndexIt];
    }
    for (NSUInteger countElementsInFirstBatchIt = countElementsInFirstBatch, i = 0;
         countElementsInFirstBatchIt < (countElementsInFirstBatch + numberOfElementsInSecondBatch) && i < numberOfElementsInSecondBatch;
         countElementsInFirstBatchIt++, i++) {
        newStorage[countElementsInFirstBatchIt] = _storage[i];
    }

    @synchronized (self) {
        _count = count;
        _pushNextIndex = count;
        _storage = newStorage;
    }
}

- (void)enqueue:(nonnull id)element {
    if (self.count == _storage.count) {
        [self resizeTo:MAX(_storage.count, 1) * _resizeFactor];
    }

    @synchronized (self) {
        _storage[_pushNextIndex] = element;
        _pushNextIndex += 1;
        _count += 1;
    }

    if (_pushNextIndex >= _storage.count) {
        _pushNextIndex -= _storage.count;
    }
}

- (nonnull id)dequeueElementOnly {
    NSUInteger index = [self dequeueIndex];
    id element = _storage[index];
    @synchronized (self) {
        _storage[index] = [EXTNil null];
        _count -= 1;
    }
    return element;
}

- (nullable id)dequeue {
    if (self.count == 0) {
        return nil;
    }

    id element = [self dequeueElementOnly];

    float downsizeLimit = _storage.count / (_resizeFactor * _resizeFactor);
    if (_count < downsizeLimit && downsizeLimit >= _initialCapacity) {
        [self resizeTo:_storage.count / _resizeFactor];
    }

    return element;
}

- (nonnull NSArray<id> *)array {
    NSMutableArray<id> *array = [NSMutableArray arrayWithCapacity:_count];
    for (NSUInteger i = [self dequeueIndex], count = _count; count > 0; i++, count--) {
        if (i >= _storage.count) {
            i -= _storage.count;
        }
        [array addObject:_storage[i]];
    }
    return array;
}

@end