//
//  RxTakeWhile
//  RxObjC
// 
//  Created by Pavel Malkov on 02.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTakeWhile.h"
#import "RxSink.h"

@interface RxTakeWhileSink<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxTakeWhileSink {
    RxTakeWhile *__nonnull _parent;
    BOOL _running;
}

- (nonnull instancetype)initWithParent:(nonnull RxTakeWhile *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _running = YES;
        _parent = parent;
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    if (event.type == RxEventTypeNext) {
        if (!_running) {
            return;
        }
        rx_tryCatch(self, ^{
            _running = _parent->_predicate(event.element);
            if (_running) {
                [self forwardOn:[RxEvent next:event.element]];
            } else {
                [self forwardOn:[RxEvent completed]];
                [self dispose];
            }
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

@interface RxTakeWhileSinkWithIndex<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxTakeWhileSinkWithIndex {
    RxTakeWhile *__nonnull _parent;
    BOOL _running;
    NSUInteger _index;
}

- (nonnull instancetype)initWithParent:(nonnull RxTakeWhile *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _running = YES;
        _index = 0;
        _parent = parent;
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    if (event.type == RxEventTypeNext) {
        if (!_running) {
            return;
        }
        rx_tryCatch(self, ^{
            _running = _parent->_indexPredicate(event.element, _index);
            rx_incrementChecked(&_index);
            if (_running) {
                [self forwardOn:[RxEvent next:event.element]];
            } else {
                [self forwardOn:[RxEvent completed]];
                [self dispose];
            }
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

@implementation RxTakeWhile

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source predicate:(RxTakeWhilePredicate)predicate {
    return [self initWithSource:source predicate:predicate indexPredicate:nil];
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source indexPredicate:(RxTakeWhileWithIndexPredicate)indexPredicate {
    return [self initWithSource:source predicate:nil indexPredicate:indexPredicate];
}

- (instancetype)initWithSource:(RxObservable *)source
                     predicate:(RxTakeWhilePredicate)predicate
                indexPredicate:(RxTakeWhileWithIndexPredicate)indexPredicate {
    self = [super init];
    if (self) {
        _source = source;
        _predicate = predicate;
        _indexPredicate = indexPredicate;
    }
    return self;
}


- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxSink *sink;
    if (_predicate) {
        sink = [[RxTakeWhileSink alloc] initWithParent:self observer:observer];
    } else if (_indexPredicate) {
        sink = [[RxTakeWhileSinkWithIndex alloc] initWithParent:self observer:observer];
    }
    sink.disposable = [_source subscribe:sink];
    return sink;
}

@end