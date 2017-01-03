//
//  RxScan
//  RxObjC
// 
//  Created by Pavel Malkov on 02.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxScan.h"
#import "RxSink.h"

@interface RxScanSink<ElementType, Accumulate, O : id<RxObserverType>> : RxSink<O> <RxObserverType>
@property (nonnull, readonly) RxScan<ElementType, Accumulate> *parent;
@property (nonnull, readonly) Accumulate accumulate;
@end

@implementation RxScanSink

- (nonnull instancetype)initWithParent:(nonnull RxScan *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
        _accumulate = _parent->_seed;
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            rx_tryCatch(^{
                _accumulate = _parent->_accumulator(_accumulate, event.element);
                [self forwardOn:[RxEvent next:_accumulate]];
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

@implementation RxScan

- (instancetype)initWithSource:(nonnull RxObservable *)source seed:(nonnull id)seed accumulator:(RxScanAccumulator)accumulator {
    self = [super init];
    if (self) {
        _source = source;
        _seed = seed;
        _accumulator = accumulator;
    }

    return self;
}


- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxScanSink *sink = [[RxScanSink alloc] initWithParent:self observer:observer];
    sink.disposable = [_source subscribe:sink];
    return sink;
}

@end