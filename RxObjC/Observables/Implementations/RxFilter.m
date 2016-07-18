//
//  RxFilter
//  RxObjC
// 
//  Created by Pavel Malkov on 02.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxFilter.h"
#import "RxSink.h"

@interface RxFilterSink<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxFilterSink {
    RxFilterPredicate _predicate;
}

- (nonnull instancetype)initWithPredicate:(RxFilterPredicate)predicate observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _predicate = predicate;
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    if (event.type == RxEventTypeNext) {
        rx_tryCatch(^{
            BOOL satisfies = _predicate(event.element);
            if (satisfies) {
                [self forwardOn:[RxEvent next:event.element]];
            }
        }, ^(NSError *error) {
            [self forwardOn:[RxEvent error:event.error]];
            [self dispose];
        });
    } else {
        [self forwardOn:event];
        [self dispose];
    }
}

@end

@implementation RxFilter {
    RxObservable *__nonnull _source;
    RxFilterPredicate __nonnull _predicate;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source predicate:(RxFilterPredicate)predicate {
    self = [super init];
    if (self) {
        _source = source;
        _predicate = predicate;
    }

    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxFilterSink *sink = [[RxFilterSink alloc] initWithPredicate:_predicate observer:observer];
    sink.disposable = [_source subscribe:sink];
    return sink;
}

@end