//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxToArray.h"
#import "RxObserverType.h"
#import "RxSink.h"
#import "RxObservable.h"

@interface RxToArraySink<SourceType, O : id <RxObserverType/*<NSArray <SourceType>>*/>> : RxSink<O> <RxObserverType>
@end

@implementation RxToArraySink {
    __weak RxToArray<id> *__nullable _parent;
    NSMutableArray<id> *__nonnull _list;
}

- (nonnull instancetype)initWithParent:(RxToArray<id> *)parent andObserver:(id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _list = [NSMutableArray array];
        _parent = parent;
    }
    return self;
}

- (void)on:(nonnull RxEvent<id> *)event {
    switch (event.type) {
        case RxEventTypeNext:
            [_list addObject:event.element];
            break;
        case RxEventTypeError: {
            [self forwardOn:event];
            [self dispose];
            break;
        }
        case RxEventTypeCompleted: {
            [self forwardOn:[RxEvent next:_list]];
            [self forwardOn:[RxEvent completed]];
            [self dispose];
            break;
        }
    }
}

@end

@implementation RxToArray {
    RxObservable<id> *__nonnull _source;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source {
    self = [super init];
    if (self) {
        _source = source;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxToArraySink<id, NSArray<id> *> *sink = [[RxToArraySink alloc] initWithParent:self andObserver:observer];
    sink.disposable = [_source subscribe:sink];
    return sink;
}


@end