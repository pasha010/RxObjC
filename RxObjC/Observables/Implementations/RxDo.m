//
//  RxDo
//  RxObjC
// 
//  Created by Pavel Malkov on 28.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxDo.h"
#import "RxSink.h"

@interface RxDoSink<O : id<RxObserverType>> : RxSink<O> <RxObserverType>
@end

@implementation RxDoSink {
    RxDo *__nonnull _parent;
}

- (nonnull instancetype)initWithParent:(nonnull RxDo *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    rx_tryCatch(^{
        _parent->_eventHandler(event);
        [self forwardOn:event];
        if (event.isStopEvent) {
            [self dispose];
        }
    }, ^(NSError *error) {
        [self forwardOn:[RxEvent error:error]];
        [self dispose];
    });
}

@end

@implementation RxDo

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source eventHandler:(nonnull RxDoOnEventHandler)eventHandler {
    self = [super init];
    if (self) {
        _source = source;
        _eventHandler = eventHandler;
    }

    return self;
}


- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxDoSink *sink = [[RxDoSink alloc] initWithParent:self observer:observer];
    sink.disposable = [_source subscribe:sink];
    return sink;
}

@end