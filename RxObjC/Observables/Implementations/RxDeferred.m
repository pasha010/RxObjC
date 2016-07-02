//
//  RxDeferred
//  RxObjC
// 
//  Created by Pavel Malkov on 25.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxDeferred.h"
#import "RxSink.h"
#import "RxNopDisposable.h"

@interface RxDeferredSink<S : id <RxObservableType>, O : id <RxObserverType>> : RxSink<O> <RxObserverType>
@end

@implementation RxDeferredSink {
    RxObservableFactory _observableFactory;
}
- (instancetype)initWithObservableFactory:(RxObservableFactory)observableFactory observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _observableFactory = observableFactory;
    }

    return self;
}

- (nonnull id <RxDisposable>)run {
    __block id <RxDisposable> res = nil;
    rx_tryCatch(self, ^{
        RxObservable *result = _observableFactory();
        res = [result subscribe:self];
    }, ^(NSError *error) {
        [self forwardOn:[RxEvent error:error]];
        [self dispose];
        res = [RxNopDisposable sharedInstance];
    });
    return res;
}

- (void)on:(nonnull RxEvent *)event {
    [self forwardOn:event];
    if (event.type != RxEventTypeNext) {
        [self dispose];
    }
}


@end

@implementation RxDeferred {
    RxObservableFactory _observableFactory;
}

- (nonnull instancetype)initWithObservableFactory:(RxObservableFactory)observableFactory {
    self = [super init];
    if (self) {
        _observableFactory = observableFactory;
    }
    return self;
}

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    RxDeferredSink *sink = [[RxDeferredSink alloc] initWithObservableFactory:_observableFactory observer:observer];
    sink.disposable = [sink run];
    return sink;
}


@end