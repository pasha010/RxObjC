//
//  RxDelaySubscription
//  RxObjC
// 
//  Created by Pavel Malkov on 08.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxDelaySubscription.h"
#import "RxSink.h"

@interface RxDelaySubscriptionSink<O : id <RxObserverType>> : RxSink<O> <RxObserverType>
@end

@implementation RxDelaySubscriptionSink {
    RxDelaySubscription *__nonnull _parent;
}

- (nonnull instancetype)initWithParent:(nonnull RxDelaySubscription *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    [self forwardOn:event];
    if (event.isStopEvent) {
        [self dispose];
    }
}

@end

@implementation RxDelaySubscription

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source
                               dueTime:(RxTimeInterval)dueTime
                             scheduler:(nonnull id <RxSchedulerType>)scheduler {
    self = [super init];
    if (self) {
        _source = source;
        _dueTime = dueTime;
        _scheduler = scheduler;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    __block RxDelaySubscriptionSink *sink = [[RxDelaySubscriptionSink alloc] initWithParent:self observer:observer];
    @weakify(self);
    sink.disposable = [_scheduler scheduleRelative:nil dueTime:_dueTime action:^id <RxDisposable>(id o) {
        @strongify(self);
        return [self->_source subscribe:sink];
    }];
    return sink;
}

@end