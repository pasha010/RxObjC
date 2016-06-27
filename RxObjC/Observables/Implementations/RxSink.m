//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSink.h"
#import "RxObserverType.h"
#import "RxProducer.h"

@interface RxSinkForwarder<__covariant O : id <RxObserverType>> : NSObject <RxObserverType>
@end

@implementation RxSinkForwarder {
    RxSink<id <RxObserverType>> *__nonnull _forward;
}

- (nonnull instancetype)initWithForward:(nonnull RxSink<id <RxObserverType>> *)forward {
    self = [super init];
    if (self) {
        _forward = forward;
    }
    return self;
}

- (void)on:(nonnull RxEvent<id <RxObserverType>> *)event {
    [_forward->_observer on:event];
    if (event.type != RxEventTypeNext) {
        [_forward dispose];
    }
}

@end

void rx_tryCatch(id self, void (^tryBlock)(), void (^catchBlock)(NSError *)) {
    @try {
        tryBlock();
    }
    @catch (id e) {
        NSError *error = e;
        if ([e isKindOfClass:[NSException class]]) {
            NSException *exception = e;
            error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@ + %@", NSStringFromClass([self class]), exception.name]
                                        code:[self hash]
                                    userInfo:exception.userInfo];
        }
        catchBlock(error);
    }
}

@implementation RxSink

- (nonnull instancetype)initWithObserver:(nonnull id <RxObserverType>)observer {
    self = [super init];
    if (self) {
#if TRACE_RESOURCES
        OSAtomicIncrement32(&rx_resourceCount);
#endif
        _observer = observer;
    }
    return self;
}

- (void)forwardOn:(nonnull RxEvent<id <RxObserverType>> *)event {
    if ([self disposed]) {
        return;
    }
    [_observer on:event];
}

- (nonnull id <RxObserverType>)forwarder {
    return [[RxSinkForwarder alloc] initWithForward:self];
}

- (void)dealloc {
#if TRACE_RESOURCES
    OSAtomicDecrement32(&rx_resourceCount);
#endif
}

@end


