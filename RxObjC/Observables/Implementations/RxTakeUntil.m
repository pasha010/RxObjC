//
//  RxTakeUntil
//  RxObjC
// 
//  Created by Pavel Malkov on 28.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTakeUntil.h"
#import "RxSink.h"
#import "RxSynchronizedOnType.h"
#import "RxStableCompositeDisposable.h"
#import "RxLockOwnerType.h"

@interface RxTakeUntilSink<O : id<RxObserverType>> : RxSink<O> <RxSynchronizedOnType>
@property BOOL open;
@end

@interface RxTakeUntilSinkOther : NSObject <RxObserverType, RxLockOwnerType, RxSynchronizedOnType>
@property (nonnull, readonly) RxSingleAssignmentDisposable *subscription;
@property (nonnull, readonly) RxTakeUntilSink *parent;

@end

@implementation RxTakeUntilSinkOther

- (nonnull instancetype)initWithParent:(nonnull RxTakeUntilSink *)parent {
    self = [super init];
    if (self) {
        _subscription = [[RxSingleAssignmentDisposable alloc] init];
        _parent = parent;
#if TRACE_RESOURCES
        OSAtomicIncrement32(&rx_resourceCount);
#endif
    }
    return self;
}

#ifdef TRACE_RESOURCES
- (void)dealloc {
    OSAtomicDecrement32(&rx_resourceCount);
}
#endif

- (NSRecursiveLock *)lock {
    return _parent.lock;
}

- (void)on:(nonnull RxEvent *)event {
    rx_synchronizedOn(self, event);
}

- (void)_synchronized_on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            [_parent forwardOn:[RxEvent completed]];
            [_parent dispose];
            break;
        }
        case RxEventTypeError: {
            [_parent forwardOn:[RxEvent error:event.error]];
            [_parent dispose];
            break;
        }
        case RxEventTypeCompleted: {
            _parent.open = YES;
            [_subscription dispose];
            break;
        }
    }
}

@end

@implementation RxTakeUntilSink {
    RxTakeUntil *__nonnull _parent;
}

- (nonnull instancetype)initWithParent:(nonnull RxTakeUntil *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _open = NO;
        _parent = parent;
    }
    return self;
}

- (NSRecursiveLock *)lock {
    return _lock;
}

- (void)on:(nonnull RxEvent *)event {
    rx_synchronizedOn(self, event);
}

- (void)_synchronized_on:(nonnull RxEvent *)event {
    [self forwardOn:event];
    if (event.type != RxEventTypeNext) {
        [self dispose];
    }
}

- (nonnull id <RxDisposable>)run {
    RxTakeUntilSinkOther *otherObserver = [[RxTakeUntilSinkOther alloc] initWithParent:self];
    id <RxDisposable> otherSubscription = [_parent->_other subscribe:otherObserver];
    otherObserver.subscription.disposable = otherSubscription;
    id <RxDisposable> sourceSubscription = [_parent->_source subscribe:self];
    return [RxStableCompositeDisposable createDisposable1:sourceSubscription disposable2:otherObserver.subscription];
}

@end

@implementation RxTakeUntil

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source other:(nonnull RxObservable *)other {
    self = [super init];
    if (self) {
        _source = source;
        _other = other;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxTakeUntilSink *sink = [[RxTakeUntilSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end