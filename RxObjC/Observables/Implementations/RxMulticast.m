//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxMulticast.h"
#import "RxSubjectType.h"
#import "RxObservableBlockTypedef.h"
#import "RxSink.h"
#import "RxConnectableObservable.h"
#import "RxBinaryDisposable.h"
#import "RxNopDisposable.h"

@interface RxMulticastSink<S : id <RxSubjectType>, O : id <RxObserverType>> : RxSink<O> <RxObserverType>
@end

@implementation RxMulticastSink {
    RxMulticast<id <RxSubjectType>, id> *__nonnull _parent;
}

- (nonnull instancetype)initWithParent:(nonnull RxMulticast<id <RxSubjectType>, id> *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
    }
    return self;
}

- (nonnull id <RxDisposable>)run {
    __block id <RxDisposable> res;
    rx_tryCatch(self, ^{
        id <RxSubjectType> subject = _parent->_subjectSelector();
        RxConnectableObservableAdapter *connectable = [[RxConnectableObservableAdapter alloc] initWithSource:_parent->_source andSubject:subject];

        RxObservable *observable = _parent->_sel(connectable);

        id <RxDisposable> subscription = [observable subscribe:self];
        id <RxDisposable> connection = [connectable connect];

        res = [[RxBinaryDisposable alloc] initWithFirstDisposable:subscription andSecondDisposable:connection];
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

@implementation RxMulticast

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source
                       subjectSelector:(RxSubjectSelectorType)subjectSelector
                              selector:(RxSelectorType)sel {
    self = [super init];
    if (self) {
        _source = source;
        _subjectSelector = subjectSelector;
        _sel = sel;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxMulticastSink *sink = [[RxMulticastSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end