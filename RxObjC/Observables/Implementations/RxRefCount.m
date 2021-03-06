//
//  RxRefCount
//  RxObjC
// 
//  Created by Pavel Malkov on 23.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxRefCount.h"
#import "RxConnectableObservableType.h"
#import "RxSink.h"
#import "RxObservable+Extension.h"
#import "RxLock.h"
#import "RxAnonymousDisposable.h"

@interface RxRefCountSink<__covariant CO : RxConnectableObservable *> : RxSink <RxObserverType> {
    RxRefCount<CO> *__nonnull _parent;
}
@end

@implementation RxRefCountSink

- (nonnull instancetype)initWithParent:(nonnull RxRefCount<RxConnectableObservable *> *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
    }
    return self;
}

- (nonnull id<RxDisposable>)run {
    __block id <RxDisposable> subscription = [_parent->_source subscribeSafe:self];

    [_parent->_lock performLock:^{
        if (_parent->_count == 0) {
            _parent->_count = 1;
            _parent->_connectableSubscription = [_parent->_source connect];
        } else {
            _parent->_count++;
        }
    }];
    
    return [[RxAnonymousDisposable alloc] initWithDisposeAction:^{
        [subscription dispose];
        [self->_parent->_lock performLock:^{
            if (self->_parent->_count == 1) {
                [self->_parent->_connectableSubscription dispose];
                self->_parent->_count = 0;
                self->_parent->_connectableSubscription = nil;
            } else if (self->_parent->_count > 1) {
                self->_parent->_count--;
            } else {
                rx_fatalError(@"Something went wrong with RefCount disposing mechanism");
            }
        }];
    }];
}

- (void)on:(nonnull RxEvent<id> *)event {
    [self forwardOn:event];
    if (event.type != RxEventTypeNext) {
        [self dispose];
    }
}


@end

@implementation RxRefCount

- (nonnull instancetype)initWithSource:(nonnull RxConnectableObservable *)source {
    self = [super init];
    if (self) {
        _lock = [[NSRecursiveLock alloc] init];
        _source = source;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxRefCountSink *sink = [[RxRefCountSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}


@end