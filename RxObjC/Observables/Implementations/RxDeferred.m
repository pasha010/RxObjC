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
    @try {
        RxObservable *result = _observableFactory();
        return [result subscribe:self];
    }
    @catch (id e) {
        NSError *error = e;
        if ([e isKindOfClass:[NSException class]]) {
            NSException *exception = e;
            error = [NSError errorWithDomain:[NSString stringWithFormat:@"RxDeferredSink + %@", exception.name]
                                        code:[self hash]
                                    userInfo:exception.userInfo];
        }
        [self forwardOn:[RxEvent error:error]];
        [self dispose];
        return [RxNopDisposable sharedInstance];
    }
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