//
//  RxAnonymousObservable
//  RxObjC
// 
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxAnonymousObservable.h"
#import "RxSink.h"
#import "RxAnyObserver.h"

@interface RxAnonymousObservableSink<O : id<RxObserverType>> : RxSink<O> <RxObserverType>
@end

@implementation RxAnonymousObservableSink {
    int32_t _isStopped;
}

- (nonnull instancetype)initWithObserver:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _isStopped = 0;
    }
    return self;
}

- (void)on:(RxEvent *)event {
    if (event.type == RxEventTypeNext) {
        if (_isStopped == 1) {
            return;
        }
        [self forwardOn:event];
    } else {
        if (OSAtomicCompareAndSwap32(0, 1, &_isStopped)) {
            [self forwardOn:event];
            [self dispose];
        }
    }
}

- (nonnull id <RxDisposable>)run:(RxAnonymousObservable *)parent {
    return parent.subscribeHandler([[RxAnyObserver alloc] initWithObserver:self]);
}

@end

@implementation RxAnonymousObservable

- (nonnull instancetype)initWithSubscribeHandler:(RxAnonymousSubscribeHandler)subscribeHandler {
    self = [super init];
    if (self) {
        _subscribeHandler = subscribeHandler;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxAnonymousObservableSink *sink = [[RxAnonymousObservableSink alloc] initWithObserver:observer];
    sink.disposable = [sink run:self];
    return sink;
    /*
     * let sink = AnonymousObservableSink(observer: observer)
        sink.disposable = sink.run(self)
        return sink
     */
}


@end