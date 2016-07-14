//
//  RxMerge(Private)
//  RxObjC
// 
//  Created by Pavel Malkov on 27.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxMerge+Private.h"
#import "RxCompositeDisposable.h"
#import "RxBag.h"
#import "RxLock.h"


@implementation RxMergeSinkIter

- (nonnull instancetype)initWithParent:(nonnull RxMergeSink *)parent disposeKey:(nonnull RxBagKey *)disposeKey {
    self = [super init];
    if (self) {
        _parent = parent;
        _disposeKey = disposeKey;
    }

    return self;
}

- (void)on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            [_parent->_lock performLock:^{
                [_parent forwardOn:[RxEvent next:event.element]];
            }];
            break;
        }
        case RxEventTypeError: {
            [_parent->_lock performLock:^{
                [_parent forwardOn:[RxEvent error:event.error]];
                [_parent dispose];
            }];
            break;
        }
        case RxEventTypeCompleted: {
            [_parent.group removeDisposable:_disposeKey];
            // If this has returned true that means that `Completed` should be sent.
            // In case there is a race who will sent first completed,
            // lock will sort it out. When first Completed message is sent
            // it will set observer to nil, and thus prevent further complete messages
            // to be sent, and thus preserving the sequence grammar.
            if (_parent.stopped && _parent.group.count == RxMergeNoIterators) {
                [_parent->_lock performLock:^{
                    [_parent forwardOn:[RxEvent completed]];
                    [_parent dispose];
                }];
            }
            break;
        }
    }
}

@end

@implementation RxMergeSink

- (nonnull instancetype)initWithObserver:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _group = [[RxCompositeDisposable alloc] init];
        _sourceSubscription = [[RxSingleAssignmentDisposable alloc] init];
        _stopped = NO;
    }
    return self;
}

- (BOOL)subscribeNext {
    return YES;
}

- (nonnull id <RxObservableConvertibleType>)performMap:(nonnull id)element {
    return rx_abstractMethod();
}

- (void)on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            if (!self.subscribeNext) {
                return;
            }
            rx_tryCatch(^{
                id <RxObservableConvertibleType> value = [self performMap:event.element];
                [self subscribeInner:[value asObservable]];
            }, ^(NSError *error) {
                [self forwardOn:[RxEvent error:error]];
                [self dispose];
            });

            break;
        }
        case RxEventTypeError: {
            [_lock performLock:^{
                [self forwardOn:[RxEvent error:event.error]];
                [self dispose];
            }];
            break;
        }
        case RxEventTypeCompleted: {
            [_lock performLock:^{
                _stopped = YES;
                if (_group.count == RxMergeNoIterators) {
                    [self forwardOn:[RxEvent completed]];
                    [self dispose];
                } else {
                    [_sourceSubscription dispose];
                }
            }];
            break;
        }
    }
}

- (void)subscribeInner:(nonnull RxObservable *)source {
    RxSingleAssignmentDisposable *iterDisposable = [[RxSingleAssignmentDisposable alloc] init];
    RxBagKey *disposeKey = [_group addDisposable:iterDisposable];
    if (disposeKey) {
        RxMergeSinkIter *iter = [[RxMergeSinkIter alloc] initWithParent:self disposeKey:disposeKey];
        id <RxDisposable> subscription = [source subscribe:iter];
        iterDisposable.disposable = subscription;
    }
}

- (nonnull id <RxDisposable>)run:(nonnull RxObservable *)source {
    [_group addDisposable:_sourceSubscription];

    id <RxDisposable> subscription = [source subscribe:self];
    _sourceSubscription.disposable = subscription;

    return _group;
}

@end