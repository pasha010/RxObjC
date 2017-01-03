//
//  RxCatch
//  RxObjC
// 
//  Created by Pavel Malkov on 28.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxCatch.h"
#import "RxSink.h"
#import "RxSerialDisposable.h"
#import "RxTailRecursiveSink.h"

@interface RxCatchSink<O : id<RxObserverType>> : RxSink<O> <RxObserverType>
@end

@interface RxCatchSinkProxy<O: id <RxObserverType>> : NSObject <RxObserverType>
@end

@implementation RxCatchSinkProxy {
    RxCatchSink *__nonnull _parent;
}

- (nonnull instancetype)initWithParent:(nonnull RxCatchSink *)parent {
    self = [super init];
    if (self) {
        _parent = parent;
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    [_parent forwardOn:event];

    if (event.type != RxEventTypeNext) {
        [_parent dispose];
    }
}


@end

@implementation RxCatchSink {
    RxCatch *__nonnull _parent;
    RxSerialDisposable *__nonnull _subscription;
}

- (nonnull instancetype)initWithParent:(nonnull RxCatch *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
        _subscription = [[RxSerialDisposable alloc] init];
    }
    return self;
}

- (nonnull id <RxDisposable>)run {
    RxSingleAssignmentDisposable *d1 = [[RxSingleAssignmentDisposable alloc] init];
    _subscription.disposable = d1;
    d1.disposable = [_parent->_source subscribe:self];
    return _subscription;
}

- (void)on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            [self forwardOn:event];
            break;
        }
        case RxEventTypeError: {
            rx_tryCatch(^{
                RxObservable *catchSequence = _parent->_handler(event.error);

                RxCatchSinkProxy *observer = [[RxCatchSinkProxy alloc] initWithParent:self];

                _subscription.disposable = [catchSequence subscribe:observer];
            }, ^(NSError *error) {
                [self forwardOn:[RxEvent error:error]];
                [self dispose];
            });
            break;
        }
        case RxEventTypeCompleted: {
            [self forwardOn:event];
            [self dispose];
            break;
        }
    }
}

@end

@implementation RxCatch

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source handler:(RxCatchHandler)handler {
    self = [super init];
    if (self) {
        _source = source;
        _handler = handler;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxCatchSink *sink = [[RxCatchSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end

@interface RxCatchSequenceSink<O : id<RxObserverType>> : RxTailRecursiveSink <RxObserverType>
@end

@implementation RxCatchSequenceSink {
    NSError *__nullable _lastError;
}

- (void)on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            [self forwardOn:event];
            break;
        }
        case RxEventTypeError: {
            _lastError = event.error;
            [self schedule:RxTailRecursiveSinkCommandMoveNext];
            break;
        }
        case RxEventTypeCompleted: {
            [self forwardOn:event];
            [self dispose];
            break;
        }
    }
}

- (nonnull id <RxDisposable>)subscribeToNext:(nonnull RxObservable *)source {
    return [source subscribe:self];
}

- (void)done {
    if (_lastError) {
        [self forwardOn:[RxEvent error:_lastError]];
    } else {
        [self forwardOn:[RxEvent completed]];
    }
    [self dispose];
}

- (nullable RxTuple2<NSEnumerator<id <RxObservableConvertibleType>> *, NSNumber *> *)extract:(nonnull RxObservable *)observable {
    if ([observable isKindOfClass:[RxCatchSequence class]]) {
        RxCatchSequence *onError = (RxCatchSequence *) observable;
        return [RxTuple2 tupleWithArray:@[onError->_sources, [RxNil null]]];
    } else {
        return nil;
    }
}

@end

@implementation RxCatchSequence

- (nonnull instancetype)initWithSources:(nonnull NSEnumerator *)sources {
    self = [super init];
    if (self) {
        _sources = sources;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxCatchSequenceSink *sink = [[RxCatchSequenceSink alloc] initWithObserver:observer];
    sink.disposable = [sink run:[RxTuple2 tupleWithArray:@[_sources, [RxNil null]]]];
    return sink;
}

@end