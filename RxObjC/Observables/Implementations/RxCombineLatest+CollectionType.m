//
//  RxCombineLatest(CollectionType)
//  RxObjC
// 
//  Created by Pavel Malkov on 03.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxCombineLatest+CollectionType.h"
#import "RxSink.h"
#import "RxAnyObserver.h"
#import "RxCompositeDisposable.h"

@interface RxCombineLatestCollectionTypeSink<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxCombineLatestCollectionTypeSink {
    RxCombineLatestCollectionType *__nonnull _parent;
    NSUInteger _numberOfValues;
    NSMutableArray<id> *__nonnull _values;
    NSMutableArray<NSNumber/* BOOL */ *> *__nonnull _isDone;
    NSUInteger _numberOfDone;
    NSMutableArray<RxSingleAssignmentDisposable *> *__nonnull _subscriptions;
}

- (nonnull instancetype)initWithParent:(nonnull RxCombineLatestCollectionType *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _numberOfValues = 0;
        _values = [NSMutableArray arrayWithCapacity:parent->_count];
        _isDone = [NSMutableArray arrayWithCapacity:parent->_count];
        _subscriptions = [NSMutableArray arrayWithCapacity:parent->_count];
        _parent = parent;

        for (NSUInteger i = 0; i < parent->_count; i++) {
            _values[i] = [EXTNil null];
            _isDone[i] = @NO;
            [_subscriptions addObject:[[RxSingleAssignmentDisposable alloc] init]];
        }
    }
    return self;
}

- (nonnull NSRecursiveLock *)lock {
    return _lock;
}

- (nonnull id <RxDisposable>)run {
    @weakify(self);
    for (NSUInteger i = 0; i < _parent->_sources.count; i++) {
        NSUInteger index = i;
        id <RxObservableConvertibleType> s = _parent->_sources[i];
        RxObservable *source = [s asObservable];
        _subscriptions[i].disposable = [source subscribe:[[RxAnyObserver alloc] initWithEventHandler:^(RxEvent *event) {
            @strongify(self);
            [self on:event atIndex:index];
        }]];
    }
    return [[RxCompositeDisposable alloc] initWithDisposableArray:[_subscriptions copy]];
}

- (void)on:(nonnull RxEvent *)event atIndex:(NSUInteger)atIndex {
    [_lock lock];

    switch (event.type) {
        case RxEventTypeNext: {
            if (_values[atIndex] == [EXTNil null]) {
                _numberOfValues++;
            }
            
            _values[atIndex] = event.element;
            
            if (_numberOfValues < _parent->_count) {
                NSUInteger numberOfOthersThatAreDone = _numberOfDone - (_isDone[atIndex].boolValue ? 1 : 0);
                if (numberOfOthersThatAreDone == _parent->_count - 1) {
                    [self forwardOn:[RxEvent completed]];
                    [self dispose];
                }
                return;
            }
            
            rx_tryCatch(^{
                id result = _parent->_resultSelector(_values);
                [self forwardOn:[RxEvent next:result]];
            }, ^(NSError *error) {
                [self forwardOn:[RxEvent error:error]];
                [self dispose];
            });
            
            break;
        }
        case RxEventTypeError: {
            [self forwardOn:[RxEvent error:event.error]];
            [self dispose];
            break;
        }
        case RxEventTypeCompleted: {
            if (_isDone[atIndex]) {
                return;
            }

            _isDone[atIndex] = @YES;
            _numberOfDone++;
            if (_numberOfDone == _parent->_count) {
                [self forwardOn:[RxEvent completed]];
                [self dispose];
            } else {
                [_subscriptions[atIndex] dispose];
            }

            break;
        }
    }
        
    [_lock unlock];
}

@end

@implementation RxCombineLatestCollectionType

- (nonnull instancetype)initWithSources:(nonnull NSArray<id <RxObservableConvertibleType>> *)sources resultSelector:(RxCombineLatestResultSelector)resultSelector {
    self = [super init];
    if (self) {
        _sources = sources;
        _resultSelector = resultSelector;
        _count = _sources.count;
    }

    return self;
}


- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxCombineLatestCollectionTypeSink *sink = [[RxCombineLatestCollectionTypeSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end