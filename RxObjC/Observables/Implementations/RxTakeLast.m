//
//  RxTakeLast
//  RxObjC
// 
//  Created by Pavel Malkov on 02.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTakeLast.h"
#import "RxSink.h"
#import "RxQueue.h"

@interface RxTakeLastSink<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxTakeLastSink {
    RxTakeLast *__nonnull _parent;
    RxQueue *__nonnull _elements;
}

- (nonnull instancetype)initWithParent:(nonnull RxTakeLast *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _elements = [[RxQueue alloc] initWithCapacity:parent->_count + 1];
        _parent = parent;
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            [_elements enqueue:event.element];
            if (_elements.count > _parent->_count) {
                [_elements dequeue];
            }
            break;
        }
        case RxEventTypeError: {
            [self forwardOn:event];
            [self dispose];
            break;
        }
        case RxEventTypeCompleted: {
            for (id element in _elements) {
                [self forwardOn:[RxEvent next:element]];
            }
            [self forwardOn:[RxEvent completed]];
            [self dispose];
            break;
        }
    }
}

@end

@implementation RxTakeLast

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source count:(NSUInteger)count {
    self = [super init];
    if (self) {
        _source = source;
        _count = count;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxTakeLastSink *sink = [[RxTakeLastSink alloc] initWithParent:self observer:observer];
    sink.disposable = [_source subscribe:sink];
    return sink;
}

@end