//
//  RxSkipUntil
//  RxObjC
// 
//  Created by Pavel Malkov on 28.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSkipUntil.h"
#import "RxSink.h"
#import "RxSynchronizedOnType.h"
#import "RxStableCompositeDisposable.h"
#import "RxLockOwnerType.h"

@interface RxSkipUntilSink<O : id<RxObserverType>> : RxSink<O>

@property BOOL forwardElements;
@property (nonnull, readonly) RxSingleAssignmentDisposable *sourceSubscription;

@end

@interface RxSkipUntilSinkOther : NSObject <RxObserverType, RxLockOwnerType, RxSynchronizedOnType>
@property (nonnull, readonly) RxSingleAssignmentDisposable *subscription;
@property (nonnull, readonly) RxSkipUntilSink *parent;

@end

@implementation RxSkipUntilSinkOther

- (nonnull instancetype)initWithParent:(nonnull RxSkipUntilSink *)parent {
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
    [self synchronizedOn:event];
}

- (void)_synchronized_on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            _parent.forwardElements = YES;
            [_subscription dispose];
            break;
        }
        case RxEventTypeError: {
            [_parent forwardOn:[RxEvent error:event.error]];
            [_parent dispose];
            break;
        }
        case RxEventTypeCompleted: {
            [_subscription dispose];
            break;
        }
    }
}

@end

@implementation RxSkipUntilSink {
    RxSkipUntil *__nonnull _parent;
}

- (nonnull instancetype)initWithParent:(nonnull RxSkipUntil *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _forwardElements = NO;
        _sourceSubscription = [[RxSingleAssignmentDisposable alloc] init];
        _parent = parent;
    }
    return self;
}

- (NSRecursiveLock *)lock {
    return _lock;
}

- (void)on:(nonnull RxEvent *)event {
    [self synchronizedOn:event];
}

- (void)_synchronized_on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            if (_forwardElements) {
                [self forwardOn:event];
            }
            break;
        }
        case RxEventTypeError: {
            [self forwardOn:event];
            [self dispose];
            break;
        }
        case RxEventTypeCompleted: {
            if (_forwardElements) {
                [self forwardOn:event];
            }
            [_sourceSubscription dispose];
            break;
        }
    }
}

- (nonnull id <RxDisposable>)run {
    id <RxDisposable> sourceSubscription = [_parent->_source subscribe:self];
    RxSkipUntilSinkOther *otherObserver = [[RxSkipUntilSinkOther alloc] initWithParent:self];
    id <RxDisposable> otherSubscription = [_parent->_other subscribe:otherObserver];
    _sourceSubscription.disposable = sourceSubscription;
    otherObserver.subscription.disposable = otherSubscription;

    return [RxStableCompositeDisposable createDisposable1:_sourceSubscription disposable2:otherObserver.subscription];
}

@end

@implementation RxSkipUntil

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source other:(nonnull RxObservable *)other {
    self = [super init];
    if (self) {
        _source = source;
        _other = other;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxSkipUntilSink *sink = [[RxSkipUntilSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end