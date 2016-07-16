//
//  RxZip(CollectionType)
//  RxObjC
// 
//  Created by Pavel Malkov on 04.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxZip+CollectionType.h"
#import "RxSink.h"
#import "RxQueue.h"
#import "RxAnyObserver.h"
#import "RxCompositeDisposable.h"
#import "RxPriorityQueue.h"

@interface RxZipCollectionTypeSink<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxZipCollectionTypeSink {
    RxZipCollectionType *__nonnull _parent;
    NSUInteger _numberOfValues;
    NSUInteger _numberOfDone;
    NSMutableArray<RxQueue *> *__nonnull _values;
    NSMutableArray<NSNumber/*BOOL*/ *> *__nonnull _isDone;
    NSMutableArray<RxSingleAssignmentDisposable *> *__nonnull _subscriptions;
}

- (nonnull instancetype)initWithParent:(nonnull RxZipCollectionType *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
        _numberOfValues = 0;
        _numberOfDone = 0;
        _values = [NSMutableArray arrayWithCapacity:parent->_count];
        _isDone = [NSMutableArray arrayWithCapacity:parent->_count];
        _subscriptions = [NSMutableArray arrayWithCapacity:parent->_count];
        for (NSUInteger i = 0; i < parent->_count; i++) {
            [_subscriptions addObject:[[RxSingleAssignmentDisposable alloc] init]];
            [_values addObject:[[RxQueue alloc] initWithCapacity:4]];
            [_isDone addObject:@NO];
        }
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event atIndex:(NSUInteger)index {
    [_lock lock];
    
    switch (event.type) {
        case RxEventTypeNext: {
            [_values[index] enqueue:event.element];
            
            if (_values[index].count == 1) {
                _numberOfValues++;
            }
            
            if (_numberOfValues < _parent->_count) {
                NSUInteger numberOfOthersThatAreDone = _numberOfDone + (_isDone[index].boolValue ? 1 : 0);
                if (numberOfOthersThatAreDone == _parent->_count - 1) {
                    [self forwardOn:[RxEvent completed]];
                    [self dispose];
                }
                [_lock unlock];
                return;
            }
            
            rx_tryCatch(^{
                NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:_parent->_count];
                
                _numberOfValues = 0;
                for (NSUInteger i = 0; i < _values.count; i++) {
                    [arguments addObject:[_values[i] dequeue]];
                    if (_values[i].count > 0) {
                        _numberOfValues++;
                    }
                }

                id result = _parent->_resultSelector(arguments);
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
            if (_isDone[index].boolValue) {
                [_lock unlock];
                return;
            }

            _isDone[index] = @YES;
            _numberOfDone++;

            if (_numberOfDone == _parent->_count) {
                [self forwardOn:[RxEvent completed]];
                [self dispose];
            } else {
                [_subscriptions[index] dispose];
            }

            break;
        }
    }
    
    
    [_lock unlock];
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

@end

@implementation RxZipCollectionType

- (instancetype)initWithSources:(NSArray<id <RxObservableConvertibleType>> *)sources resultSelector:(RxZipCollectionTypeResultSelector)resultSelector {
    self = [super init];
    if (self) {
        _sources = sources;
        _resultSelector = resultSelector;
        _count = _sources.count;
    }

    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxZipCollectionTypeSink *sink = [[RxZipCollectionTypeSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end