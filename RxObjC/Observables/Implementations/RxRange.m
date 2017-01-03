//
//  RxRange
//  RxObjC
// 
//  Created by Pavel Malkov on 25.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxRange.h"

#import "RxSink.h"
#import "RxImmediateSchedulerType.h"

@interface RxRangeProducerSink<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxRangeProducerSink {
    RxRangeProducer *__nonnull _parent;
}

- (nonnull instancetype)initWithParent:(nonnull RxRangeProducer *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
    }
    return self;
}

- (nonnull id <RxDisposable>)run {
    return [_parent->_scheduler scheduleRecursive:@0.0 action:^(NSNumber *i, void (^recurse)(id)) {
        if (i.integerValue < self->_parent->_count) {
            [self forwardOn:[RxEvent next:@(self->_parent->_start + i.integerValue)]];
            recurse(@(i.doubleValue + 1));
        } else {
            [self forwardOn:[RxEvent completed]];
            [self dispose];
        }
    }];
}

@end

@implementation RxRangeProducer

- (nonnull instancetype)initWithStart:(NSInteger)start
                                count:(NSUInteger)count 
                            scheduler:(nonnull RxImmediateScheduler *)scheduler {
    self = [super init];
    if (self) {
        _start = start;
        _count = count;
        _scheduler = scheduler;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxRangeProducerSink *sink = [[RxRangeProducerSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end