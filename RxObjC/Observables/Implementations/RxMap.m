//
//  RxMap
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxMap.h"
#import "RxObjCCommon.h"
#import "RxSink.h"

@interface RxMapSink<SourceType, O : id <RxObserverType>> : RxSink<O> <RxObserverType>
@end

@implementation RxMapSink {
    RxMapSelector _selector;
}

- (nonnull instancetype)initWithSelector:(RxMapSelector)selector observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _selector = selector;
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            rx_tryCatch(^{
                id mappedElement = _selector(event.element);
                [self forwardOn:[RxEvent next:mappedElement]];
            }, ^(NSError *error) {
                [self forwardOn:[RxEvent error:error]];
                [self dispose];
            });
            break;
        }
        case RxEventTypeError: {
            [self forwardOn:[RxEvent error:event.error]];
            [self dispose];
            break;
        }
        case RxEventTypeCompleted: {
            [self forwardOn:[RxEvent completed]];
            [self dispose];
            break;
        }
    }
}

@end

@implementation RxMap {
    RxMapSelector _selector;
    RxObservable *__nonnull _source;
}
- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source selector:(RxMapSelector)selector {
    self = [super init];
    if (self) {
        _source = source;
        _selector = selector;
#if TRACE_RESOURCES
        OSAtomicIncrement32(&rx_numberOfMapOperators);
#endif
    }
    return self;
}

- (RxObservable *)_composeMap:(RxMapSelector)selector {
    RxMapSelector originalSelector = _selector;
    return [[RxMap alloc] initWithSource:_source selector:^id(id o) {
        id r = originalSelector(o);
        return selector(r);
    }];
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxMapSink *sink = [[RxMapSink alloc] initWithSelector:_selector observer:observer];
    sink.disposable = [_source subscribe:sink];
    return sink;
}

#if TRACE_RESOURCES
- (void)dealloc {
    OSAtomicDecrement32(&rx_numberOfMapOperators);
}
#endif

@end

@interface RxMapWithIndexSink<SourceType, O : id <RxObserverType>> : RxSink<O> <RxObserverType>
@end

@implementation RxMapWithIndexSink {
    RxMapWithIndexSelector _selector;
    NSInteger _index;
}

- (nonnull instancetype)initWithSelector:(RxMapWithIndexSelector)selector observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _index = 0;
        _selector = selector;
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    if (event.type == RxEventTypeNext) {
        rx_tryCatch(^{
            id mappedElement = _selector(event.element, rx_incrementChecked(&_index));
            [self forwardOn:[RxEvent next:mappedElement]];
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

@implementation RxMapWithIndex {
    RxMapWithIndexSelector _selector;
    RxObservable *__nonnull _source;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source selector:(RxMapWithIndexSelector)selector {
    self = [super init];
    if (self) {
        _source = source;
        _selector = selector;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxMapWithIndexSink *sink = [[RxMapWithIndexSink alloc] initWithSelector:_selector observer:observer];
    sink.disposable = [_source subscribe:sink];
    return sink;
}

@end