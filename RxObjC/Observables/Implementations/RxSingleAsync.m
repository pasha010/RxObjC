//
//  RxSingleAsync
//  RxObjC
// 
//  Created by Pavel Malkov on 04.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSingleAsync.h"
#import "RxSink.h"
#import "RxError.h"

@interface RxSingleAsyncSink<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxSingleAsyncSink {
    RxSingleAsync *__nonnull _parent;
    BOOL _seenValue;
}

- (nonnull instancetype)initWithParent:(nonnull RxSingleAsync *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
        _seenValue = NO;
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            rx_tryCatch(^{
                BOOL forward = _parent->_predicate != nil ? _parent->_predicate(event.element) : YES;

                if (!forward) {
                    return;
                }

                if (!_seenValue) {
                    _seenValue = YES;
                    [self forwardOn:[RxEvent next:event.element]];
                } else {
                    [self forwardOn:[RxEvent error:[RxError moreThanOneElement]]];
                    [self dispose];
                }

            }, ^(NSError *error) {
                [self forwardOn:[RxEvent error:error]];
                [self dispose];
            });
            break;
        }
        case RxEventTypeError: {
            [self forwardOn:event];
            [self dispose];
            break;
        }
        case RxEventTypeCompleted: {
            if (!_seenValue) {
                [self forwardOn:[RxEvent error:[RxError noElements]]];
            } else {
                [self forwardOn:[RxEvent completed]];
            }
            [self dispose];
            break;
        }
    }
}

@end

@implementation RxSingleAsync

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source {
    return [self initWithSource:source predicate:nil];
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source predicate:(nullable RxSingleAsyncPredicate)predicate {
    self = [super init];
    if (self) {
        _source = source;
        _predicate = predicate;
    }
    return self;
}


- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxSingleAsyncSink *sink = [[RxSingleAsyncSink alloc] initWithParent:self observer:observer];
    sink.disposable = [_source subscribe:sink];
    return sink;
}

@end