//
//  RxZip(Private)
//  RxObjC
// 
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxZip+Private.h"
#import "RxCompositeDisposable.h"
#import "RxQueue.h"
#import "RxTuple.h"

@implementation RxZipArraySink {
    RxZipArray *__nonnull _parent;
    NSArray<RxQueue *> *__nonnull _values;
}

- (nonnull instancetype)initWithParent:(nonnull RxZipArray *)parent andObserver:(nonnull id <RxObserverType>)observer {
    self = [super initWithArity:parent.sources.count andObserver:observer];
    if (self) {
        _parent = parent;
        NSUInteger count = parent.sources.count;
        NSMutableArray<RxQueue *> *values = [NSMutableArray arrayWithCapacity:count];
        for (NSUInteger i = 0; i < count; i++) {
            values[i] = [[RxQueue alloc] initWithCapacity:2];
        }
        _values = [values copy];
    }
    return self;
}

- (BOOL)hasElements:(NSUInteger)index {
    if (_values.count > index) {
        return _values[index].count > 0;
    }
    return NO;
}

- (id)getResult {
    NSMutableArray *res = [NSMutableArray arrayWithCapacity:_values.count];
    for (RxQueue *queue in _values) {
        [res addObject:queue.dequeue];
    }
    return _parent.tupleResultSelector([RxTuple tupleWithArray:res]);
}

- (nonnull id<RxDisposable>)run {
    NSUInteger count = _values.count;
    NSMutableArray<RxSingleAssignmentDisposable *> *subscriptions = [NSMutableArray arrayWithCapacity:count];
    @weakify(self);
    for (NSUInteger i = 0; i < count; i++) {
        RxSingleAssignmentDisposable *subscription = [[RxSingleAssignmentDisposable alloc] init];
        RxZipObserver *observer = [[RxZipObserver alloc] initWithLock:self.lock 
                                                               parent:self 
                                                                index:i 
                                                         setNextValue:^(id o) {
                                                             @strongify(self); 
                                                             return [self->_values[i] enqueue:o];
                                                         } this:subscription];
        subscription.disposable = [_parent.sources[i] subscribe:observer];
        [subscriptions addObject:subscription];
    }
    return [[RxCompositeDisposable alloc] initWithDisposableArray:subscriptions];
}

@end

@implementation RxZipArray

- (nonnull instancetype)initWithSources:(nonnull NSArray<RxObservable *> *)sources resultSelector:(RxZipTupleResultSelector)resultSelector {
    self = [super init];
    if (self) {
        _sources = sources;
        _tupleResultSelector = resultSelector;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxZipArraySink *sink = [[RxZipArraySink alloc] initWithParent:self andObserver:observer];
    sink.disposable = [sink run];
    return sink;
}

@end

@implementation RxZip2

- (nonnull instancetype)initWithSource1:(nonnull RxObservable *)source1 and:(nonnull RxObservable *)source2 resultSelector:(RxZip2ResultSelector)resultSelector {
    self = [super initWithSources:@[source1, source2] resultSelector:^id(RxTuple *tuple) {
        RxTupleUnpack(id o1, id o2) = tuple;
        return resultSelector(o1, o2);
    }];
    return self;
}

@end

@implementation RxZip3

- (nonnull instancetype)initWithSource1:(nonnull RxObservable *)source1 and:(nonnull RxObservable *)source2 and:(nonnull RxObservable *)source3 resultSelector:(RxZip3ResultSelector)resultSelector {
    self = [super initWithSources:@[source1, source2, source3] resultSelector:^id(RxTuple *tuple) {
        RxTupleUnpack(id o1, id o2, id o3) = tuple;
        return resultSelector(o1, o2, o3);
    }];
    return self;
}

@end

@implementation RxZip4

- (nonnull instancetype)initWithSource1:(nonnull RxObservable *)source1 and:(nonnull RxObservable *)source2 and:(nonnull RxObservable *)source3 and:(nonnull RxObservable *)source4 resultSelector:(RxZip4ResultSelector)resultSelector {
    self = [super initWithSources:@[source1, source2, source3, source4] resultSelector:^id(RxTuple *tuple) {
        RxTupleUnpack(id o1, id o2, id o3, id o4) = tuple;
        return resultSelector(o1, o2, o3, o4);
    }];
    return self;
}

@end

@implementation RxZip7

- (nonnull instancetype)initWithSource1:(nonnull RxObservable *)source1 and:(nonnull RxObservable *)source2 and:(nonnull RxObservable *)source3 and:(nonnull RxObservable *)source4 and:(nonnull RxObservable *)source5 and:(nonnull RxObservable *)source6 and:(nonnull RxObservable *)source7 resultSelector:(RxZip7ResultSelector)resultSelector {
    self = [super initWithSources:@[source1, source2, source3, source4, source5, source6, source7] resultSelector:^id(RxTuple *tuple) {
        RxTupleUnpack(id o1, id o2, id o3, id o4, id o5, id o6, id o7) = tuple;
        return resultSelector(o1, o2, o3, o4, o5, o6, o7);
    }];
    return self;
}

@end

@implementation RxZip8

- (nonnull instancetype)initWithSource1:(nonnull RxObservable *)source1 and:(nonnull RxObservable *)source2 and:(nonnull RxObservable *)source3 and:(nonnull RxObservable *)source4 and:(nonnull RxObservable *)source5 and:(nonnull RxObservable *)source6 and:(nonnull RxObservable *)source7 and:(nonnull RxObservable *)source8 resultSelector:(RxZip8ResultSelector)resultSelector {
    self = [super initWithSources:@[source1, source2, source3, source4, source5, source6, source7, source8] resultSelector:^id(RxTuple *tuple) {
        RxTupleUnpack(id o1, id o2, id o3, id o4, id o5, id o6, id o7, id o8) = tuple;
        return resultSelector(o1, o2, o3, o4, o5, o6, o7, o8);
    }];
    return self;
}

@end

/*@implementation RxZip8Sink {
    RxZip8 *__nonnull _parent;
    RxQueue *__nonnull _values1;
    RxQueue *__nonnull _values2;
    RxQueue *__nonnull _values3;
    RxQueue *__nonnull _values4;
    RxQueue *__nonnull _values5;
    RxQueue *__nonnull _values6;
    RxQueue *__nonnull _values7;
    RxQueue *__nonnull _values8;
}

- (nonnull instancetype)initWithParent:(nonnull RxZip8 *)parent observer:(nonnull id<RxObserverType>)observer {
    self = [super initWithArity:8 andObserver:observer];
    if (self) {
        _parent = parent;
        _values1 = [[RxQueue alloc] initWithCapacity:2];
        _values2 = [[RxQueue alloc] initWithCapacity:2];
        _values3 = [[RxQueue alloc] initWithCapacity:2];
        _values4 = [[RxQueue alloc] initWithCapacity:2];
        _values5 = [[RxQueue alloc] initWithCapacity:2];
        _values6 = [[RxQueue alloc] initWithCapacity:2];
        _values7 = [[RxQueue alloc] initWithCapacity:2];
        _values8 = [[RxQueue alloc] initWithCapacity:2];
    }
    return self;
}

- (BOOL)hasElements:(NSUInteger)index {
    switch (index) {
        case 0: return _values1.count > 0;
        case 1: return _values2.count > 0;
        case 2: return _values3.count > 0;
        case 3: return _values4.count > 0;
        case 4: return _values5.count > 0;
        case 5: return _values6.count > 0;
        case 6: return _values7.count > 0;
        case 7: return _values8.count > 0;
        default:
            rx_fatalError(@"Unhandled case (Function)");
    }
    return NO;
}

- (id)getResult {
    return _parent.resultSelector([_values1 dequeue], [_values2 dequeue], [_values3 dequeue], [_values4 dequeue], [_values5 dequeue], [_values6 dequeue], [_values7 dequeue], [_values8 dequeue]);
}

- (nonnull id<RxDisposable>)run {
    RxSingleAssignmentDisposable *subscription1 = [[RxSingleAssignmentDisposable alloc] init];
    RxSingleAssignmentDisposable *subscription2 = [[RxSingleAssignmentDisposable alloc] init];
    RxSingleAssignmentDisposable *subscription3 = [[RxSingleAssignmentDisposable alloc] init];
    RxSingleAssignmentDisposable *subscription4 = [[RxSingleAssignmentDisposable alloc] init];
    RxSingleAssignmentDisposable *subscription5 = [[RxSingleAssignmentDisposable alloc] init];
    RxSingleAssignmentDisposable *subscription6 = [[RxSingleAssignmentDisposable alloc] init];
    RxSingleAssignmentDisposable *subscription7 = [[RxSingleAssignmentDisposable alloc] init];
    RxSingleAssignmentDisposable *subscription8 = [[RxSingleAssignmentDisposable alloc] init];
    
    @weakify(self);
    RxZipObserver *observer1 = [[RxZipObserver alloc] initWithLock:self.lock parent:self index:0 setNextValue:^(id o) {@strongify(self); return [self->_values1 enqueue:o];} this:subscription1];
    RxZipObserver *observer2 = [[RxZipObserver alloc] initWithLock:self.lock parent:self index:1 setNextValue:^(id o) {@strongify(self); return [self->_values2 enqueue:o];} this:subscription2];
    RxZipObserver *observer3 = [[RxZipObserver alloc] initWithLock:self.lock parent:self index:2 setNextValue:^(id o) {@strongify(self); return [self->_values3 enqueue:o];} this:subscription3];
    RxZipObserver *observer4 = [[RxZipObserver alloc] initWithLock:self.lock parent:self index:3 setNextValue:^(id o) {@strongify(self); return [self->_values4 enqueue:o];} this:subscription4];
    RxZipObserver *observer5 = [[RxZipObserver alloc] initWithLock:self.lock parent:self index:4 setNextValue:^(id o) {@strongify(self); return [self->_values5 enqueue:o];} this:subscription5];
    RxZipObserver *observer6 = [[RxZipObserver alloc] initWithLock:self.lock parent:self index:5 setNextValue:^(id o) {@strongify(self); return [self->_values6 enqueue:o];} this:subscription6];
    RxZipObserver *observer7 = [[RxZipObserver alloc] initWithLock:self.lock parent:self index:6 setNextValue:^(id o) {@strongify(self); return [self->_values7 enqueue:o];} this:subscription7];
    RxZipObserver *observer8 = [[RxZipObserver alloc] initWithLock:self.lock parent:self index:7 setNextValue:^(id o) {@strongify(self); return [self->_values8 enqueue:o];} this:subscription8];

    subscription1.disposable = [_parent.source1 subscribe:observer1];
    subscription2.disposable = [_parent.source2 subscribe:observer2];
    subscription3.disposable = [_parent.source3 subscribe:observer3];
    subscription4.disposable = [_parent.source4 subscribe:observer4];
    subscription5.disposable = [_parent.source5 subscribe:observer5];
    subscription6.disposable = [_parent.source6 subscribe:observer6];
    subscription7.disposable = [_parent.source7 subscribe:observer7];
    subscription8.disposable = [_parent.source8 subscribe:observer8];

    return [[RxCompositeDisposable alloc] initWithDisposableArray:@[
            subscription1,
            subscription2,
            subscription3,
            subscription4,
            subscription5,
            subscription6,
            subscription7,
            subscription8
    ]];
}

@end

@implementation RxZip8

- (nonnull instancetype)initWithSource1:(nonnull RxObservable *)source1 and:(nonnull RxObservable *)source2 and:(nonnull RxObservable *)source3 and:(nonnull RxObservable *)source4 and:(nonnull RxObservable *)source5 and:(nonnull RxObservable *)source6 and:(nonnull RxObservable *)source7 and:(nonnull RxObservable *)source8 resultSelector:(RxZip8ResultSelector)resultSelector {
    self = [super init];
    if (self) {
        _source1 = source1;
        _source2 = source2;
        _source3 = source3;
        _source4 = source4;
        _source5 = source5;
        _source6 = source6;
        _source7 = source7;
        _source8 = source8;
        _resultSelector = resultSelector;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxZip8Sink *sink = [[RxZip8Sink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end*/
