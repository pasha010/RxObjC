//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxPriorityQueue.h"


@implementation RxPriorityQueue {
    BOOL (^_hasHigherPriority)(id __nonnull , id __nonnull);
    NSMutableArray<id> *__nonnull _elements;
}

- (nonnull instancetype)initWithHasHigherPriority:(BOOL(^)(id __nonnull , id __nonnull ))hasHigherPriority {
    self = [super init];
    if (self) {
        _hasHigherPriority = hasHigherPriority;
        _elements = [NSMutableArray array];
    }
    return self;
}

- (void)enqueue:(nonnull id)element {
    [_elements addObject:element];
    [self bubbleToHigherPriority:_elements.count - 1];
}

- (nullable id)peek {
    return _elements.firstObject;
}

- (BOOL)isEmpty {
    return _elements.count == 0;
}

- (nullable id)dequeue {
    id front = [self peek];
    if (!front) {
        return nil;
    }
    
    [self removeAt:0];
    
    return front;
}

- (void)remove:(nonnull id)element {
    NSUInteger i = 0;
    for (id e in _elements) {
        if ([e isEqual:element]) {
            [self removeAt:i];
            return;
        }
        i++;
    }
}

- (void)removeAt:(NSUInteger)index {
    BOOL removingLast = index == _elements.count - 1;
    if (!removingLast) {
        [_elements exchangeObjectAtIndex:index withObjectAtIndex:_elements.count - 1];
    }

    [_elements removeLastObject];
    
    if (!removingLast) {
        [self bubbleToHigherPriority:index];
        [self bubbleToLowerPriority:index];
    }
}

- (void)bubbleToHigherPriority:(NSUInteger)initialUnbalancedIndex {
    if (initialUnbalancedIndex >= _elements.count) {
        return;
    }

    NSUInteger unbalancedIndex = initialUnbalancedIndex;

    while (unbalancedIndex > 0) {
        NSUInteger parentIndex = (unbalancedIndex - 1) / 2;
        if (_hasHigherPriority(_elements[unbalancedIndex], _elements[parentIndex])) {
            [_elements exchangeObjectAtIndex:unbalancedIndex withObjectAtIndex:parentIndex];

            unbalancedIndex = parentIndex;
        } else {
            break;
        }
    }
}

- (void)bubbleToLowerPriority:(NSUInteger)initialUnbalancedIndex {
    if (initialUnbalancedIndex >= _elements.count) {
        return;
    }
    NSUInteger unbalancedIndex = initialUnbalancedIndex;

    do {
        NSUInteger leftChildIndex = unbalancedIndex * 2 + 1;
        NSUInteger rightChildIndex = unbalancedIndex * 2 + 2;

        NSUInteger highestPriorityIndex = unbalancedIndex;

        if (leftChildIndex < _elements.count && _hasHigherPriority(_elements[leftChildIndex], _elements[highestPriorityIndex])) {
            highestPriorityIndex = leftChildIndex;
        }

        if (rightChildIndex < _elements.count && _hasHigherPriority(_elements[rightChildIndex], _elements[highestPriorityIndex])) {
            highestPriorityIndex = rightChildIndex;
        }

        if (highestPriorityIndex != unbalancedIndex) {
            [_elements exchangeObjectAtIndex:highestPriorityIndex withObjectAtIndex:unbalancedIndex];
            unbalancedIndex = highestPriorityIndex;
        } else {
            break;
        }

    } while (YES);
}

- (NSString *)debugDescription {
    return _elements.debugDescription;
}


- (NSString *)description {
    return self.description;
}


@end