//
//  RxCombineLatest
//  RxObjC
// 
//  Created by Pavel Malkov on 03.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxCombineLatest.h"


@implementation RxCombineLatestSink {
    NSUInteger _numberOfValues;
    NSUInteger _numberOfDone;
    NSMutableArray<NSNumber *> *__nonnull _hasValue;
    NSMutableArray<NSNumber *> *__nonnull _isDone;
}

- (nonnull instancetype)initWithArity:(NSUInteger)arity observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _arity = arity;
        _numberOfValues = 0;
        _numberOfDone = 0;
        _hasValue = [NSMutableArray arrayWithCapacity:arity];
        _isDone = [NSMutableArray arrayWithCapacity:arity];
        for (NSUInteger i = 0; i < arity; i++) {
            [_hasValue addObject:@NO];
            [_isDone addObject:@NO];
        }
    }
    return self;
}

- (nonnull id)getResult {
    return rx_abstractMethod();
}

- (void)next:(NSUInteger)index {
    if (!_hasValue[index].boolValue) {
        _hasValue[index] = @YES;
        _numberOfValues++;
    }

    if (_numberOfValues == _arity) {
        rx_tryCatch(self, ^{
            id result = [self getResult];
            [self forwardOn:[RxEvent next:result]];
        }, ^(NSError *error) {
            [self forwardOn:[RxEvent error:error]];
            [self dispose];
        });
    } else {
        BOOL allOthersDone = YES;
        for (NSUInteger i = 0; i < _arity; i++) {
            if (i != index && !_isDone[i].boolValue) {
                allOthersDone = NO;
                break;
            }
        }

        if (allOthersDone) {
            [self forwardOn:[RxEvent completed]];
            [self dispose];
        }
    }
}

- (void)fail:(nonnull NSError *)error {
    [self forwardOn:[RxEvent error:error]];
    [self dispose];
}

- (void)done:(NSUInteger)index {
    if (_isDone[index].boolValue) {
        return;
    }

    _isDone[index] = @YES;
    _numberOfDone++;

    if (_numberOfDone == _arity) {
        [self forwardOn:[RxEvent completed]];
        [self dispose];
    }
}

@end

@implementation RxCombineLatestObserver {
    NSRecursiveLock *__nonnull _lock;
    id <RxCombineLatestProtocol> __nonnull _parent;
    NSUInteger _index;
    RxCombineLatestValueSetter _setLatestValue;
    id <RxDisposable> __nonnull _this;
}

- (nonnull instancetype)initWithLock:(nonnull NSRecursiveLock *)lock
                              parent:(nonnull id <RxCombineLatestProtocol>)parent
                               index:(NSUInteger)index
                      setLatestValue:(RxCombineLatestValueSetter)setLatestValue
                                this:(nonnull id <RxDisposable>)this {
    self = [super init];
    if (self) {
        _lock = lock;
        _parent = parent;
        _index = index;
        _setLatestValue = setLatestValue;
        _this = this;
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
            _setLatestValue(event.element);
            [_parent next:_index];
            break;
        }
        case RxEventTypeError: {
            [_this dispose];
            [_parent fail:event.error];
            break;
        }
        case RxEventTypeCompleted: {
            [_this dispose];
            [_parent done:_index];
            break;
        }
    }
}

@end