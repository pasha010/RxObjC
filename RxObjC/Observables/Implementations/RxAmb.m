//
//  RxAmb
//  RxObjC
// 
//  Created by Pavel Malkov on 28.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxAmb.h"
#import "RxSink.h"
#import "RxStableCompositeDisposable.h"
#import "RxLock.h"

typedef NS_ENUM(NSUInteger, RxAmbState) {
    RxAmbStateNeither,
    RxAmbStateLeft,
    RxAmbStateRight
};

@interface RxAmbSink<O : id <RxObserverType>> : RxSink<O>
@end

@class RxAmbObserver;

typedef void (^RxAmbSinkAction)(RxAmbObserver *__nonnull, RxEvent *__nonnull);

@interface RxAmbObserver : NSObject <RxObserverType>

@property (nonnull, nonatomic, strong, readonly) RxAmbSink *parent;
@property (nonatomic, copy, readwrite) RxAmbSinkAction sink;
@property (nonnull, nonatomic, strong, readwrite) id <RxDisposable> cancel;

@end

@implementation RxAmbObserver

- (nonnull instancetype)initWithParent:(nonnull RxAmbSink *)parent cancel:(nonnull id <RxDisposable>)cancel sink:(RxAmbSinkAction)sink {
    self = [super init];
    if (self) {
        _parent = parent;
        _cancel = cancel;
        _sink = sink;
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

- (void)on:(nonnull RxEvent *)event {
    self.sink(self, event);
    if (event.isStopEvent) {
        [self.cancel dispose];
    }
}


@end

@implementation RxAmbSink {
    RxAmb *__nonnull _parent;
    RxAmbState _choice;
}

- (nonnull instancetype)initWithParent:(nonnull RxAmb *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _choice = RxAmbStateNeither;
        _parent = parent;
    }
    return self;
}

- (nonnull id <RxDisposable>)run {
    RxSingleAssignmentDisposable *subscription1 = [[RxSingleAssignmentDisposable alloc] init];
    RxSingleAssignmentDisposable *subscription2 = [[RxSingleAssignmentDisposable alloc] init];
    __block id <RxDisposable> disposeAll = [RxStableCompositeDisposable createDisposable1:subscription1 disposable2:subscription2];

    @weakify(self);
    RxAmbSinkAction forwardEvent = ^(RxAmbObserver *__nonnull o, RxEvent *__nonnull event) {
        @strongify(self);
        [self forwardOn:event];
    };

    void (^decide)(RxAmbObserver *, RxEvent *, RxAmbState, id <RxDisposable>)=^(RxAmbObserver *__nonnull o, RxEvent *__nonnull event, RxAmbState me, id <RxDisposable> __nonnull otherSubscription) {
        @strongify(self);
        [self->_lock performLock:^{
            if (self->_choice == RxAmbStateNeither) {
                self->_choice = me;
                o.sink = forwardEvent;
                o.cancel = disposeAll;
                [otherSubscription dispose];
            }
            
            if (self->_choice == me) {
                [self forwardOn:event];
                if (event.isStopEvent) {
                    [self dispose];
                }
            }
        }];
    };

    RxAmbObserver *sink1 = [[RxAmbObserver alloc] initWithParent:self cancel:subscription1 sink:^(RxAmbObserver *__nonnull _o, RxEvent *__nonnull e) {
        decide(_o, e, RxAmbStateLeft, subscription2);
    }];


    RxAmbObserver *sink2 = [[RxAmbObserver alloc] initWithParent:self cancel:subscription1 sink:^(RxAmbObserver *__nonnull _o, RxEvent *__nonnull e) {
        decide(_o, e, RxAmbStateRight, subscription1);
    }];

    subscription1.disposable = [_parent->_left subscribe:sink1];
    subscription2.disposable = [_parent->_right subscribe:sink2];

    return disposeAll;
}

@end

@implementation RxAmb

- (nonnull instancetype)initWithLeft:(nonnull RxObservable *)left right:(nonnull RxObservable *)right {
    self = [super init];
    if (self) {
        _left = left;
        _right = right;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxAmbSink *sink = [[RxAmbSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end