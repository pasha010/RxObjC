//
//  RxCombineLatest(Private)
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxCombineLatest+Private.h"
#import "RxSink.h"
#import "RxCompositeDisposable.h"
#import "RxTuple.h"

@interface RxCombineLatestArraySink<E, O : id <RxObserverType>> : RxCombineLatestSink<O>
@end

@implementation RxCombineLatestArraySink {
    RxCombineLatestArray *__nonnull _parent;
    NSMutableDictionary *__nonnull _latestElements;
}

- (nonnull instancetype)initWithParent:(nonnull RxCombineLatestArray *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithArity:parent->_sources.count observer:observer];
    if (self) {
        _parent = parent;
        _latestElements = [NSMutableDictionary dictionaryWithCapacity:_arity];
    }
    return self;
}

- (nonnull id <RxDisposable>)run {
    NSMutableArray<id <RxDisposable>> *disposables = [NSMutableArray arrayWithCapacity:_arity];

    @weakify(self);
    for (NSUInteger i = 0; i < _arity; i++) {
        RxSingleAssignmentDisposable *subscription = [[RxSingleAssignmentDisposable alloc] init];
        __block NSUInteger index = i;
        RxCombineLatestObserver *observer = [[RxCombineLatestObserver alloc] initWithLock:_lock
                                                                                   parent:self
                                                                                    index:i
                                                                           setLatestValue:^(id element) {
                                                                               @strongify(self);
                                                                               self->_latestElements[@(index)] = element;
                                                                           } this:subscription];

        subscription.disposable = [_parent->_sources[i] subscribe:observer];
        [disposables addObject:subscription];
    }
    
    return [[RxCompositeDisposable alloc] initWithDisposableArray:disposables];
}

- (nonnull id)getResult {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:_arity];
    for (NSUInteger i = 0; i < _arity; i++) {
        [array addObject:_latestElements[@(i)] ? : [EXTNil null]];
    }
    return _parent->_resultSelector([RxTuple tupleWithArray:array]);
}

@end

@implementation RxCombineLatestArray

- (nonnull instancetype)initWithSources:(nonnull NSArray<RxObservable<id> *> *)sources
                         resultSelector:(RxCombineLatestTupleResultSelector)resultSelector {
    self = [super init];
    if (self) {
        _sources = sources;
        _resultSelector = resultSelector;
    }
    return self;
}


- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxCombineLatestArraySink *sink = [[RxCombineLatestArraySink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end

@implementation RxCombineLatest2

- (nonnull instancetype)initWithSource1:(nonnull RxObservable *)source1 source2:(nonnull RxObservable *)source2 resultSelector:(RxCombineLatest2ResultSelector)resultSelector {
    self = [super initWithSources:@[source1, source2] resultSelector:^id(RxTuple *__nonnull tuple) {
        RxTupleUnpack(id o1, id o2) = tuple;
        if (o1 == [EXTNil null]) {
            o1 = nil;
        }
        if (o2 == [EXTNil null]) {
            o2 = nil;
        }
        return resultSelector(o1, o2);
    }];
    return self;
}

@end

@implementation RxCombineLatest3

- (nonnull instancetype)initWithSource1:(nonnull RxObservable *)source1
                                source2:(nonnull RxObservable *)source2
                                source3:(nonnull RxObservable *)source3
                         resultSelector:(RxCombineLatest3ResultSelector)resultSelector {
    self = [super initWithSources:@[source1, source2, source3] resultSelector:^id(RxTuple *__nonnull tuple) {
        RxTupleUnpack(id o1, id o2, id o3) = tuple;
        if (o1 == [EXTNil null]) {
            o1 = nil;
        }
        if (o2 == [EXTNil null]) {
            o2 = nil;
        }
        if (o3 == [EXTNil null]) {
            o3 = nil;
        }
        return resultSelector(o1, o2, o3);
    }];
    return self;
}

@end

@implementation RxCombineLatest4

- (nonnull instancetype)initWithSource1:(nonnull RxObservable *)source1
                                source2:(nonnull RxObservable *)source2
                                source3:(nonnull RxObservable *)source3
                                source4:(nonnull RxObservable *)source4
                         resultSelector:(RxCombineLatest4ResultSelector)resultSelector {
    self = [super initWithSources:@[source1, source2, source3, source4] resultSelector:^id(RxTuple *__nonnull tuple) {
        RxTupleUnpack(id o1, id o2, id o3, id o4) = tuple;
        if (o1 == [EXTNil null]) {
            o1 = nil;
        }
        if (o2 == [EXTNil null]) {
            o2 = nil;
        }
        if (o3 == [EXTNil null]) {
            o3 = nil;
        }
        if (o4 == [EXTNil null]) {
            o4 = nil;
        }
        return resultSelector(o1, o2, o3, o4);
    }];
    return self;
}

@end

@implementation RxCombineLatest5

- (nonnull instancetype)initWithSource1:(nonnull RxObservable *)source1
                                source2:(nonnull RxObservable *)source2
                                source3:(nonnull RxObservable *)source3
                                source4:(nonnull RxObservable *)source4
                                source5:(nonnull RxObservable *)source5
                         resultSelector:(RxCombineLatest5ResultSelector)resultSelector {
    self = [super initWithSources:@[source1, source2, source3, source4, source5] resultSelector:^id(RxTuple *__nonnull tuple) {
        RxTupleUnpack(id o1, id o2, id o3, id o4, id o5) = tuple;
        if (o1 == [EXTNil null]) {
            o1 = nil;
        }
        if (o2 == [EXTNil null]) {
            o2 = nil;
        }
        if (o3 == [EXTNil null]) {
            o3 = nil;
        }
        if (o4 == [EXTNil null]) {
            o4 = nil;
        }
        if (o5 == [EXTNil null]) {
            o5 = nil;
        }
        return resultSelector(o1, o2, o3, o4, o5);
    }];
    return self;
}

@end

@implementation RxCombineLatest6

- (nonnull instancetype)initWithSource1:(nonnull RxObservable *)source1
                                source2:(nonnull RxObservable *)source2
                                source3:(nonnull RxObservable *)source3
                                source4:(nonnull RxObservable *)source4
                                source5:(nonnull RxObservable *)source5
                                source6:(nonnull RxObservable *)source6
                         resultSelector:(RxCombineLatest6ResultSelector)resultSelector {
    self = [super initWithSources:@[source1, source2, source3, source4, source5, source6] resultSelector:^id(RxTuple *__nonnull tuple) {
        RxTupleUnpack(id o1, id o2, id o3, id o4, id o5, id o6) = tuple;
        if (o1 == [EXTNil null]) {
            o1 = nil;
        }
        if (o2 == [EXTNil null]) {
            o2 = nil;
        }
        if (o3 == [EXTNil null]) {
            o3 = nil;
        }
        if (o4 == [EXTNil null]) {
            o4 = nil;
        }
        if (o5 == [EXTNil null]) {
            o5 = nil;
        }
        if (o6 == [EXTNil null]) {
            o6 = nil;
        }
        return resultSelector(o1, o2, o3, o4, o5, o6);
    }];
    return self;
}

@end

@implementation RxCombineLatest7

- (nonnull instancetype)initWithSource1:(nonnull RxObservable *)source1
                                source2:(nonnull RxObservable *)source2
                                source3:(nonnull RxObservable *)source3
                                source4:(nonnull RxObservable *)source4
                                source5:(nonnull RxObservable *)source5
                                source6:(nonnull RxObservable *)source6
                                source7:(nonnull RxObservable *)source7
                         resultSelector:(RxCombineLatest7ResultSelector)resultSelector {
    self = [super initWithSources:@[source1, source2, source3, source4, source5, source6, source7] resultSelector:^id(RxTuple *__nonnull tuple) {
        RxTupleUnpack(id o1, id o2, id o3, id o4, id o5, id o6, id o7) = tuple;
        if (o1 == [EXTNil null]) {
            o1 = nil;
        }
        if (o2 == [EXTNil null]) {
            o2 = nil;
        }
        if (o3 == [EXTNil null]) {
            o3 = nil;
        }
        if (o4 == [EXTNil null]) {
            o4 = nil;
        }
        if (o5 == [EXTNil null]) {
            o5 = nil;
        }
        if (o6 == [EXTNil null]) {
            o6 = nil;
        }
        if (o7 == [EXTNil null]) {
            o7 = nil;
        }
        return resultSelector(o1, o2, o3, o4, o5, o6, o7);
    }];
    return self;
}

@end

@implementation RxCombineLatest8

- (nonnull instancetype)initWithSource1:(nonnull RxObservable *)source1
                                source2:(nonnull RxObservable *)source2
                                source3:(nonnull RxObservable *)source3
                                source4:(nonnull RxObservable *)source4
                                source5:(nonnull RxObservable *)source5
                                source6:(nonnull RxObservable *)source6
                                source7:(nonnull RxObservable *)source7
                                source8:(nonnull RxObservable *)source8
                         resultSelector:(RxCombineLatest8ResultSelector)resultSelector {
    self = [super initWithSources:@[source1, source2, source3, source4, source5, source6, source7, source8] resultSelector:^id(RxTuple *__nonnull tuple) {
        RxTupleUnpack(id o1, id o2, id o3, id o4, id o5, id o6, id o7, id o8) = tuple;
        if (o1 == [EXTNil null]) {
            o1 = nil;
        }
        if (o2 == [EXTNil null]) {
            o2 = nil;
        }
        if (o3 == [EXTNil null]) {
            o3 = nil;
        }
        if (o4 == [EXTNil null]) {
            o4 = nil;
        }
        if (o5 == [EXTNil null]) {
            o5 = nil;
        }
        if (o6 == [EXTNil null]) {
            o6 = nil;
        }
        if (o7 == [EXTNil null]) {
            o7 = nil;
        }
        if (o8 == [EXTNil null]) {
            o8 = nil;
        }
        return resultSelector(o1, o2, o3, o4, o5, o6, o7, o8);
    }];
    return self;
}

@end