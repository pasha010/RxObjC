//
//  RxZip
//  RxObjC
// 
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxZip.h"
#import "RxObjC.h"

@implementation RxZipSink {
    NSUInteger _arity;
    // state
    NSMutableArray<NSNumber *> *_isDone;
}

- (nonnull instancetype)initWithArity:(NSUInteger)arity andObserver:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _lock = [[NSRecursiveLock alloc] init];
        _arity = arity;
        NSMutableArray<NSNumber *> *isDone = [NSMutableArray arrayWithCapacity:arity];
        for (NSUInteger i = 0; i < arity; i++) {
            isDone[i] = @NO;
        }
        _isDone = isDone;
    }
    return self;
}

- (nonnull id)getResult {
   return rx_abstractMethod();
}

- (BOOL)hasElements:(NSUInteger)index {
    rx_abstractMethod();
    return NO;
}

- (void)next:(NSUInteger)index {
    BOOL hasValueAll = YES;
    for (NSUInteger i = 0; i < _arity; i++) {
        if (![self hasElements:i]) {
            hasValueAll = NO;
            break;
        }
    }

    if (hasValueAll) {
        @try {
            id result = [self getResult];
            [self forwardOn:[RxEvent next:result]];
        }
        @catch (NSException *exception) {
            [self forwardOn:[RxEvent error:[NSError errorWithDomain:@"zip" code:100 userInfo:exception.userInfo]]];
            [self dispose];
        }
    } else {
        BOOL allOthersDone = YES;

        NSUInteger arity = _isDone.count;
        for (NSUInteger i = 0; i < arity; i++) {
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

- (void)fail:(NSError *)error {
    [self forwardOn:[RxEvent error:error]];
    [self dispose];
}

- (void)done:(NSUInteger)index {
    _isDone[index] = @YES;

    BOOL allDone = YES;

    for (NSNumber *number in _isDone) {
        if (!number.boolValue) {
            allDone = NO;
            break;
        }
    }

    if (allDone) {
        [self forwardOn:[RxEvent completed]];
        [self dispose];
    }
}

@end

@implementation RxZipObserver {
    RxSpinLock *__nonnull _lock;
    id <RxZipSinkProtocol> __nullable _parent;
    NSUInteger _index;
    id <RxDisposable> __nonnull _this;
    RxZipObserverValueSetter _setNextValue;
}

- (nonnull instancetype)initWithLock:(nonnull RxSpinLock *)lock
                              parent:(nonnull id<RxZipSinkProtocol>)parent
                               index:(NSUInteger)index
                        setNextValue:(RxZipObserverValueSetter)setNextValue
                                this:(nonnull id <RxDisposable>)this {
    self = [super init];
    if (self) {
        _lock = lock;
        _parent = parent;
        _index = index;
        _this = this;
        _setNextValue = setNextValue;
    }
    return self;
}

- (nonnull RxSpinLock *)lock {
    return _lock;
}

- (void)on:(nonnull RxEvent<id> *)event {
    [self synchronizedOn:event];
}

- (void)_synchronized_on:(nonnull RxEvent<id> *)event {
    if (_parent) {
        if (event.type != RxEventTypeNext) {
            [_this dispose];
        }
    }

    if (_parent) {
        switch (event.type) {
            case RxEventTypeNext:
                _setNextValue(event.element);
                [_parent next:_index];
                break;
            case RxEventTypeError:
                [_parent fail:event.error];
                break;
            case RxEventTypeCompleted:
                [_parent done:_index];
                break;
        }
    }
}


@end