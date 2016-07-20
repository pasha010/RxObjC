//
//  RxTailRecursiveSink
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTailRecursiveSink.h"
#import "RxTuple.h"
#import "RxObservableConvertibleType.h"
#import "RxSerialDisposable.h"
#import "RxAsyncLock.h"
#import "RxInvocableScheduledItem.h"
#import "RxObservable.h"


@implementation RxTailRecursiveSink {
    NSMutableArray<RxTuple2<NSEnumerator<id <RxObservableConvertibleType>> *, NSNumber *> *> *__nonnull _generators;
    BOOL _disposed;
    RxSerialDisposable *__nonnull _subscription;
    /// this is thread safe object
    RxAsyncLock<RxInvocableScheduledItem<RxTailRecursiveSink *> *> *__nonnull _gate;
}

- (nonnull instancetype)initWithObserver:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _generators = [NSMutableArray array];
        _disposed = NO;
        _subscription = [[RxSerialDisposable alloc] init];
        _gate = [[RxAsyncLock alloc] init];
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull RxTuple2<NSEnumerator<id <RxObservableConvertibleType>> *, NSNumber *> *)source {
    [_generators addObject:source];

    [self schedule:RxTailRecursiveSinkCommandMoveNext];

    return _subscription;
}

- (void)invoke:(NSNumber *)value {
    RxTailRecursiveSinkCommand command = (RxTailRecursiveSinkCommand) value.unsignedIntegerValue;
    if (command == RxTailRecursiveSinkCommandMoveNext) {
        [self moveNextCommand];
    } else {
        [self disposeCommand];
    }
}

// simple implementation for now
- (void)schedule:(RxTailRecursiveSinkCommand)command {
    [_gate invoke:[[RxInvocableScheduledItem alloc] initWithInvocable:self state:@(command)]];
}

- (void)done {
    [self forwardOn:[RxEvent completed]];
    [self dispose];
}

- (nullable RxTuple2<NSEnumerator<id <RxObservableConvertibleType>> *, NSNumber *> *)extract:(nonnull RxObservable *)observable {
    return rx_abstractMethod();
}

// should be done on gate locked
- (void)moveNextCommand {
    RxObservable *next = nil;
    do {
        RxTuple2<NSEnumerator<id <RxObservableConvertibleType>> *, NSNumber *> *tuple = _generators.lastObject;
        if (!tuple) {
            break;
        }

        if (_disposed) {
            return;
        }

        NSEnumerator<id <RxObservableConvertibleType>> *g = tuple.first;

        [_generators removeLastObject];

        NSEnumerator<id <RxObservableConvertibleType>> *e = g;

        RxObservable *nextCandidate = [[e nextObject] asObservable];
        if (!nextCandidate) {
            continue;
        }
        
        // `left` is a hint of how many elements are left in generator.
        // In case this is the last element, then there is no need to push
        // that generator on stack.
        //
        // This is an optimization used to make sure in tail recursive case
        // there is no memory leak in case this operator is used to generate non terminating
        // sequence.
        
#pragma clang diagnostic push
#pragma ide diagnostic ignored "NotSuperclass"
        if (tuple.second != [RxNil null]) {
            // `- 1` because generator.next() has just been called
            NSInteger left = tuple.second.integerValue;
            if (left - 1 >= 1) {
                [_generators addObject:[RxTuple2 tupleWithArray:@[e, @(left - 1)]]];
            }
        } else {
            [_generators addObject:[RxTuple2 tupleWithArray:@[e, [RxNil null]]]];
        }
#pragma clang diagnostic pop

        RxTuple2<NSEnumerator<id <RxObservableConvertibleType>> *, NSNumber *> *nextGenerator = [self extract:nextCandidate];
        
        if (nextGenerator) {
            [_generators addObject:nextGenerator];
#if DEBUG || TRACE_RESOURCES
            if (rx_maxTailRecursiveSinkStackSize < _generators.count) {
                rx_maxTailRecursiveSinkStackSize = _generators.count;
            }
#endif
        } else {
            next = nextCandidate;
        }
    } while (next == nil);
    
    if (!next) {
        [self done];
    } else {
        RxSingleAssignmentDisposable *disposable = [[RxSingleAssignmentDisposable alloc] init];
        _subscription.disposable = disposable;
        disposable.disposable = [self subscribeToNext:next];
    }
}

- (nonnull id <RxDisposable>)subscribeToNext:(nonnull RxObservable *)next {
    return rx_abstractMethod();
}

- (void)disposeCommand {
    _disposed = YES;
    [_generators removeAllObjects];
}

- (void)dispose {
    [super dispose];

    [_subscription dispose];

    [self schedule:RxTailRecursiveSinkCommandDispose];
}


@end