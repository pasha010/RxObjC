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
        RxZipObserver *observer = [[RxZipObserver alloc] initWithLock:_lock
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

@implementation RxZip5

- (nonnull instancetype)initWithSource1:(nonnull RxObservable<id> *)source1
                                    and:(nonnull RxObservable<id> *)source2
                                    and:(nonnull RxObservable<id> *)source3
                                    and:(nonnull RxObservable<id> *)source4
                                    and:(nonnull RxObservable<id> *)source5
                         resultSelector:(RxZip5ResultSelector)resultSelector {
    self = [super initWithSources:@[source1, source2, source3, source4, source5] resultSelector:^id(RxTuple *tuple) {
        RxTupleUnpack(id o1, id o2, id o3, id o4, id o5) = tuple;
        return resultSelector(o1, o2, o3, o4, o5);
    }];
    return self;
}

@end

@implementation RxZip6

- (nonnull instancetype)initWithSource1:(nonnull RxObservable<id> *)source1
                                    and:(nonnull RxObservable<id> *)source2
                                    and:(nonnull RxObservable<id> *)source3
                                    and:(nonnull RxObservable<id> *)source4
                                    and:(nonnull RxObservable<id> *)source5
                                    and:(nonnull RxObservable<id> *)source6
                         resultSelector:(RxZip6ResultSelector)resultSelector {
    self = [super initWithSources:@[source1, source2, source3, source4, source5, source6] resultSelector:^id(RxTuple *tuple) {
        RxTupleUnpack(id o1, id o2, id o3, id o4, id o5, id o6) = tuple;
        return resultSelector(o1, o2, o3, o4, o5, o6);
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
