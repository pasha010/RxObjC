//
//  RxSkipWhile
//  RxObjC
// 
//  Created by Pavel Malkov on 02.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSkipWhile.h"
#import "RxSink.h"

@interface RxSkipWhileSink<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxSkipWhileSink {
    RxSkipWhile *__nonnull _parent;
    BOOL _running;
}

- (nonnull instancetype)initWithParent:(nonnull RxSkipWhile *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _running = NO;
        _parent = parent;
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    if (event.isNext) {
        __block BOOL disposed = NO;
        if (!_running) {
            rx_tryCatch(^{
                _running = !(_parent->_predicate(event.element));
            }, ^(NSError *error) {
                [self forwardOn:[RxEvent error:error]];
                [self dispose];
                disposed = YES;
            });
        }
        if (disposed) {
            return;
        }
        if (_running) {
            [self forwardOn:[RxEvent next:event.element]];
        }
    } else {
        [self forwardOn:event];
        [self dispose];
    }
}

@end

@interface RxSkipWhileSinkWithIndex<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxSkipWhileSinkWithIndex {
    RxSkipWhile *__nonnull _parent;
    BOOL _running;
    NSUInteger _index;
}

- (nonnull instancetype)initWithParent:(nonnull RxSkipWhile *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _running = NO;
        _index = 0;
        _parent = parent;
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    if (event.type == RxEventTypeNext) {
        __block BOOL disposed = NO;
        if (!_running) {
            rx_tryCatch(^{
               _running = !(_parent->_indexPredicate(event.element, _index));
                rx_incrementCheckedUnsigned(&_index);

            }, ^(NSError *error) {
                [self forwardOn:[RxEvent error:error]];
                [self dispose];
                disposed = YES;
            });
        }
        if (disposed) {
            return;
        }
        if (_running) {
            [self forwardOn:[RxEvent next:event.element]];
        }
    } else {
        [self forwardOn:event];
        [self dispose];
    }
}

@end

@implementation RxSkipWhile

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source predicate:(RxSkipWhilePredicate)predicate {
    return [self initWithSource:source predicate:predicate indexPredicate:nil];
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source indexPredicate:(RxSkipWhileWithIndexPredicate)indexPredicate {
    return [self initWithSource:source predicate:nil indexPredicate:indexPredicate];
}

- (instancetype)initWithSource:(RxObservable *)source
                     predicate:(RxSkipWhilePredicate)predicate
                indexPredicate:(RxSkipWhileWithIndexPredicate)indexPredicate {
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
        sink = [[RxSkipWhileSink alloc] initWithParent:self observer:observer];
    } else if (_indexPredicate) {
        sink = [[RxSkipWhileSinkWithIndex alloc] initWithParent:self observer:observer];
    }
    sink.disposable = [_source subscribe:sink];
    return sink;
}

@end