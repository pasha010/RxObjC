//
//  RxSample
//  RxObjC
// 
//  Created by Pavel Malkov on 04.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSample.h"
#import "RxSink.h"
#import "RxLockOwnerType.h"
#import "RxSynchronizedOnType.h"
#import "RxStableCompositeDisposable.h"

@interface RxSampleSequenceSink<O : id<RxObserverType>> : RxSink<O> <RxObserverType, RxLockOwnerType, RxSynchronizedOnType>
@property (nullable) id element;
@property BOOL atEnd;
@property (nonnull) RxSample *parent;
@end

@interface RxSamplerSink : NSObject <RxObserverType, RxLockOwnerType, RxSynchronizedOnType>
@end

@implementation RxSamplerSink {
    RxSampleSequenceSink *__nonnull _parent; 
}

- (nonnull instancetype)initWithParent:(nonnull RxSampleSequenceSink *)parent {
    self = [super init];
    if (self) {
        _parent = parent;
    }
    return self;
}

- (nonnull NSRecursiveLock *)lock {
    return _parent->_lock;
}

- (void)on:(nonnull RxEvent *)event {
    [self synchronizedOn:event];
}

- (void)_synchronized_on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            id element = _parent.element;
            if (element) {
                if (_parent.parent->_onlyNew) {
                    _parent.element = nil;
                }

                [_parent forwardOn:[RxEvent next:element]];
            }

            if (_parent.atEnd) {
                [_parent forwardOn:[RxEvent completed]];
                [_parent dispose];
            }
            break;
        }
        case RxEventTypeError: {
            [_parent forwardOn:[RxEvent error:event.error]];
            [_parent dispose];
            break;
        }
        case RxEventTypeCompleted: {
            id element = _parent.element;
            if (element) {
                _parent.element = nil;
                [_parent forwardOn:[RxEvent next:element]];
            }
            if (_parent.atEnd) {
                [_parent forwardOn:[RxEvent completed]];
                [_parent dispose];
            }
            break;
        }
    }
}

@end

@implementation RxSampleSequenceSink {
    RxSingleAssignmentDisposable *__nonnull _sourceSubscription;
}

- (nonnull instancetype)initWithParent:(nonnull RxSample *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _element = nil;
        _atEnd = NO;
        _sourceSubscription = [[RxSingleAssignmentDisposable alloc] init];
        _parent = parent;
    }
    return self;
}

- (nonnull id <RxDisposable>)run {
    _sourceSubscription.disposable = [_parent->_source subscribe:self];
    id <RxDisposable> samplerSubscription = [_parent->_sampler subscribe:[[RxSamplerSink alloc] initWithParent:self]];
    
    return [RxStableCompositeDisposable createDisposable1:_sourceSubscription disposable2:samplerSubscription];
}

- (void)on:(nonnull RxEvent *)event {
    [self synchronizedOn:event];
}

- (void)_synchronized_on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            _element = event.element;
            break;
        }
        case RxEventTypeError: {
            [self forwardOn:event];
            [self dispose];
            break;
        }
        case RxEventTypeCompleted: {
            _atEnd = YES;
            [_sourceSubscription dispose];
            break;
        }
    }
}

@end

@implementation RxSample

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source sampler:(nonnull RxObservable<id> *)sampler onlyNew:(BOOL)onlyNew {
    self = [super init];
    if (self) {
        _source = source;
        _sampler = sampler;
        _onlyNew = onlyNew;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxSampleSequenceSink *sink = [[RxSampleSequenceSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end