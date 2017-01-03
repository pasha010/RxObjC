//
//  RxDistinctUntilChanged
//  RxObjC
// 
//  Created by Pavel Malkov on 28.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxDistinctUntilChanged.h"
#import "RxSink.h"

@interface RxDistinctUntilChangedSink<O : id<RxObserverType>> : RxSink<O> <RxObserverType>
@end

@implementation RxDistinctUntilChangedSink {
    RxDistinctUntilChanged *__nonnull _parent;
    id __nullable _currentKey;
}

- (nonnull instancetype)initWithParent:(nonnull RxDistinctUntilChanged *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
        _currentKey = nil;
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    if (event.type == RxEventTypeNext) {
        rx_tryCatch(^{
            id key = _parent->_selector(event.element);
            BOOL areEqual = NO;
            if (_currentKey) {
                id currentKey = _currentKey;
                areEqual = _parent->_comparer(currentKey, key);
            }

            if (areEqual) {
                return;
            }

            _currentKey = key;

            [self forwardOn:event];

        }, ^(NSError *error) {
            [self forwardOn:[RxEvent error:error]];
            [self dispose];
        });
    } else {
        [self forwardOn:event];
        [self dispose];
    }
}

@end

@implementation RxDistinctUntilChanged

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source 
                           keySelector:(RxDistinctUntilChangedKeySelector)keySelector 
                              comparer:(RxDistinctUntilChangedEqualityComparer)comparer {
    self = [super init];
    if (self) {
        _source = source;
        _selector = keySelector;
        _comparer = comparer;
    }

    return self;
}


- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxDistinctUntilChangedSink *sink = [[RxDistinctUntilChangedSink alloc] initWithParent:self observer:observer];
    sink.disposable = [_source subscribe:sink];
    return sink;
}

@end