//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxReduce.h"
#import "RxSink.h"

@interface RxReduceSink<__covariant O : id<RxObserverType>> : RxSink<O> <RxObserverType>
@end

@implementation RxReduceSink {
    /*__weak*/ RxReduce<id> *__nonnull _parent;
    RxAccumulateType _accumulation;
}

- (nonnull instancetype)initWithParent:(nonnull RxReduce<id> *)parent andObserver:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
        _accumulation = parent->_seed;
    }
    return self;
}

- (void)on:(RxEvent<id> *)event {
    if (event.type == RxEventTypeNext) {
        @try {
            _accumulation = _parent->_accumulator(_accumulation, [event element]);
        }
        @catch (NSException *exception) {
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"RxReduceSink + %@", exception.name]
                                                 code:104
                                             userInfo:exception.userInfo];
            [self forwardOn:[RxEvent error:error]];
            [self dispose];
        }
    } else if (event.type == RxEventTypeError) {
        [self forwardOn:[RxEvent error:event.error]];
        [self dispose];
    } else if (event.type == RxEventTypeCompleted) {
        RxResultType result = _parent->_mapResult(_accumulation);
        @try {
            [self forwardOn:[RxEvent next:result]];
            [self forwardOn:[RxEvent completed]];
        }
        @catch (NSException *exception) {
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"RxReduceSink + %@", exception.name]
                                                 code:104
                                             userInfo:exception.userInfo];
            [self forwardOn:[RxEvent error:error]];
        }
        [self dispose];
    }
}

@end

@implementation RxReduce

- (nonnull instancetype)initWithSource:(nonnull RxObservable<RxSourceType> *)source
                                  seed:(nonnull RxAccumulateType)seed
                           accumulator:(nonnull RxAccumulatorType)accumulator
                             mapResult:(nonnull ResultSelectorType)mapResult {
    self = [super init];
    if (self) {
        _source = source;
        _seed = seed;
        _accumulator = accumulator;
        _mapResult = mapResult;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxReduceSink *sink = [[RxReduceSink alloc] initWithParent:self andObserver:observer];
    sink.disposable = [_source subscribe:sink];
    return sink;
}


@end