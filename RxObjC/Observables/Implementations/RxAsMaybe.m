//
//  RxAsMaybe
//  RxObjC
// 
//  Created by Pavel Malkov on 31.08.17.
//  Copyright (c) 2014-2017 Pavel Malkov. All rights reserved.
//

#import "RxAsMaybe.h"
#import "RxSink.h"
#import "RxError.h"

@interface RxAsMaybeSink<__covariant O : id <RxObserverType>> : RxSink<O> <RxObserverType>

@property (nonnull, nonatomic, strong, readonly) RxAsMaybe *parent;
@property (nullable, nonatomic, strong, readonly) RxEvent *event;

@end

@implementation RxAsMaybeSink

- (nonnull instancetype)initWithParent:(nonnull RxAsMaybe *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
    }
    return self;
}

- (void)on:(nonnull RxEvent<id> *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            if (!_event) {
                [self forwardOn:[RxEvent error:RxError.moreThanOneElement]];
                [self dispose];
            }
            _event = event;
            break;
        }
        case RxEventTypeError: {
            [self forwardOn:event];
            [self dispose];
            break;
        }
        case RxEventTypeCompleted:
            if (_event) {
                [self forwardOn:_event];
            }
            [self forwardOn:[RxEvent completed]];
            [self dispose];
            break;
    }
}


@end

@interface RxAsMaybe<__covariant Element> ()

@property (nonnull, nonatomic, strong, readonly) RxObservable<Element> *source;

@end

@implementation RxAsMaybe

- (instancetype)initWithSource:(RxObservable *)source {
    self = [super init];
    if (self) {
        _source = source;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxAsMaybeSink *sink = [[RxAsMaybeSink alloc] initWithParent:self observer:observer];
    sink.disposable = [_source subscribe:sink];
    return sink;
}

@end