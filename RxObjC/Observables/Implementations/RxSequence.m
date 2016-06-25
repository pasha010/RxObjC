//
//  RxSequence
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSequence.h"
#import "RxImmediateSchedulerType.h"
#import "RxNopDisposable.h"
#import "RxSink.h"

@interface RxSequenceSink<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxSequenceSink {
    RxSequence *__nonnull _parent;
}

- (nonnull instancetype)initWithParent:(nonnull RxSequence *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
    }
    return self;
}

- (nonnull id<RxDisposable>)run {
    NSObject <RxImmediateSchedulerType> *scheduler = _parent->_scheduler;
    return [scheduler scheduleRecursive:@[@0, _parent->_elements.allObjects] action:^(NSArray *state, void (^recurse)(id)) {
        NSNumber *number = state[0];
        NSArray *array = (NSArray *) state[1];
        NSUInteger index = number.unsignedIntegerValue;
        if (index < array.count) {
            [self forwardOn:[RxEvent next:array[index]]];
            recurse(@[@(index + 1), array]);
        } else {
            [self forwardOn:[RxEvent completed]];
        }
    }];
}

@end

@implementation RxSequence

- (nonnull instancetype)initWithElements:(nonnull NSEnumerator<id> *)elements
                               scheduler:(nullable id <RxImmediateSchedulerType>)scheduler {
    self = [super init];
    if (self) {
        _elements = elements; 
        _scheduler = scheduler;
    }
    return self;
}

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    /// optimized version without scheduler

    if (!_scheduler) {
        for (id element in _elements) {
            [observer on:[RxEvent next:element]];
        }
        [observer on:[RxEvent completed]];
        return [RxNopDisposable sharedInstance];
    }

    RxSequenceSink *sink = [[RxSequenceSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}


@end