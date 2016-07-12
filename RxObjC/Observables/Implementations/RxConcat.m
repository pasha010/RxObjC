//
//  RxConcat
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxConcat.h"
#import "RxAnyObserver.h"
#import "RxTailRecursiveSink.h"

@interface RxConcatSink : RxTailRecursiveSink <RxObserverType>
@end

@implementation RxConcatSink

- (void)on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext:
            [self forwardOn:event];
            break;
        case RxEventTypeError:
            [self forwardOn:event];
            [self dispose];
            break;
        case RxEventTypeCompleted:
            [self schedule:RxTailRecursiveSinkCommandMoveNext];
            break;
    }
}

- (nonnull id <RxDisposable>)subscribeToNext:(nonnull RxObservable *)source {
    return [source subscribe:self];
}

- (nullable RxTuple2<NSEnumerator<id <RxObservableConvertibleType>> *, NSNumber *> *)extract:(nonnull RxObservable *)observable {
    if ([observable isKindOfClass:[RxConcat class]]) {
        RxConcat *source = (RxConcat *) observable;
        return [RxTuple2 tupleWithArray:@[source->_sources, @(source->_count)]];
    }
    return nil;
}

@end

@implementation RxConcat

- (nonnull instancetype)initWithSources:(nonnull NSEnumerator<id <RxObservableConvertibleType>> *)sources {
    return [self initWithSources:sources count:NSUIntegerMax];
}

- (nonnull instancetype)initWithSources:(nonnull NSEnumerator<id <RxObservableConvertibleType>> *)sources
                                  count:(NSUInteger)count {
    self = [super init];
    if (self) {
        _sources = sources;
        _count = count;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxConcatSink *sink = [[RxConcatSink alloc] initWithObserver:observer];
    sink.disposable = [sink run:[RxTuple2 tupleWithArray:@[_sources, @(_count)]]];
    return sink;
}


@end