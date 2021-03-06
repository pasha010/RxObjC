//
//  RxRetryWhen
//  RxObjC
// 
//  Created by Pavel Malkov on 28.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxRetryWhen.h"
#import "RxSink.h"
#import "RxTuple.h"
#import "RxTailRecursiveSink.h"
#import "RxPublishSubject.h"
#import "RxStableCompositeDisposable.h"

@interface RxRetryWhenSequenceSink<O : id<RxObserverType>> : RxTailRecursiveSink
@property (nullable) NSError *lastError;
@property (nonnull, readonly) RxPublishSubject<NSError *> *errorSubject;
@property (nonnull, readonly) RxObservable *handler;
@property (nonnull, readonly) RxPublishSubject<id> *notifier;
@property (nullable, readonly) Class errorClass;

@end

@interface RxRetryWhenSequenceSinkIter : RxSingleAssignmentDisposable <RxObserverType>
@property (nonnull, readonly) RxRetryWhenSequenceSink *parent;
@end

@interface RxRetryTriggerSink : NSObject <RxObserverType>
@end

@implementation RxRetryTriggerSink {
    RxRetryWhenSequenceSinkIter *__nonnull _parent;
}

- (nonnull instancetype)initWithParent:(nonnull RxRetryWhenSequenceSinkIter *)parent {
    self = [super init];
    if (self) {
        _parent = parent;
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            _parent.parent.lastError = nil;
            [_parent.parent schedule:RxTailRecursiveSinkCommandMoveNext];
            break;
        }
        case RxEventTypeError: {
            [_parent.parent forwardOn:[RxEvent error:event.error]];
            [_parent.parent dispose];
            break;
        }
        case RxEventTypeCompleted: {
            [_parent.parent forwardOn:[RxEvent completed]];
            [_parent.parent dispose];
            break;
        }
    }
}

@end

@implementation RxRetryWhenSequenceSinkIter {
    RxSingleAssignmentDisposable *__nonnull _errorHandlerSubscription;
}

- (nonnull instancetype)initWithParent:(nonnull RxRetryWhenSequenceSink *)parent {
    self = [super init];
    if (self) {
        _parent = parent;
        _errorHandlerSubscription = [[RxSingleAssignmentDisposable alloc] init];
    }
    return self;
}

- (void)on:(nonnull RxEvent<id> *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            [_parent forwardOn:event];
            break;
        }
        case RxEventTypeError: {
            NSError *error = event.error;
            _parent.lastError = error;

            if (!_parent.errorClass || [error.class isEqual:_parent.errorClass]) {
                [super dispose];

                id <RxDisposable> errorHandlerSubscription = [_parent.notifier subscribe:[[RxRetryTriggerSink alloc] initWithParent:self]];
                _errorHandlerSubscription.disposable = errorHandlerSubscription;
                [_parent.errorSubject on:[RxEvent next:error]];
            } else {
                [_parent forwardOn:[RxEvent error:error]];
                [_parent dispose];
            }
            break;
        }
        case RxEventTypeCompleted: {
            [_parent forwardOn:event];
            [_parent dispose];
            break;
        }
    }
}

- (void)dispose {
    [super dispose];
    [_errorHandlerSubscription dispose];
}

@end

@implementation RxRetryWhenSequenceSink {
    RxRetryWhenSequence *__nonnull _parent;
}

- (nonnull instancetype)initWithParent:(nonnull RxRetryWhenSequence *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _lastError = nil;
        _errorSubject = [RxPublishSubject create];
        _handler = [parent->_notificationHandler(_errorSubject) asObservable];
        _notifier = [RxPublishSubject create];
        _parent = parent;
        _errorClass = _parent->_errorClass;
    }
    return self;
}

- (void)done {
    if (_lastError) {
        [self forwardOn:[RxEvent error:_lastError]];
        _lastError = nil;
    } else {
        [self forwardOn:[RxEvent completed]];
    }
    [self dispose];
}

- (nullable RxTuple2<NSEnumerator<id <RxObservableConvertibleType>> *, NSNumber *> *)extract:(nonnull RxObservable *)observable {
    // It is important to always return `nil` here because there are sideffects in the `run` method
    // that are dependant on particular `retryWhen` operator so single operator stack can't be reused in this
    // case.
    return nil;
}

- (nonnull id <RxDisposable>)subscribeToNext:(nonnull RxObservable *)source {
    RxRetryWhenSequenceSinkIter *iter = [[RxRetryWhenSequenceSinkIter alloc] initWithParent:self];
    iter.disposable = [source subscribe:iter];
    return iter;
}

- (nonnull id <RxDisposable>)run:(nonnull RxTuple2<NSEnumerator<id <RxObservableConvertibleType>> *, NSNumber *> *)sources {
    id <RxDisposable> triggerSubscription = [_handler subscribe:[_notifier asObserver]];
    id <RxDisposable> superSubscription = [super run:sources];
    return [RxStableCompositeDisposable createDisposable1:superSubscription disposable2:triggerSubscription];
}

@end

@implementation RxRetryWhenSequence {
    NSEnumerator *__nonnull _sources;
}

- (nonnull instancetype)initWithSources:(NSEnumerator *)sequence 
                    notificationHandler:(id <RxObservableType> (^)(RxObservable<NSError *> *))handler
                       customErrorClass:(nullable Class)errorClass {
    self = [super init];
    if (self) {
        _sources = sequence;
        _notificationHandler = handler;
        _errorClass = errorClass;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxRetryWhenSequenceSink *sink = [[RxRetryWhenSequenceSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run:[RxTuple2 tupleWithArray:@[_sources, [RxNil null]]]];
    return sink;
}

@end