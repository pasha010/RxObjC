//
//  RxSubscribeOn
//  RxObjC
// 
//  Created by Pavel Malkov on 26.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSubscribeOn.h"
#import "RxSink.h"
#import "RxImmediateSchedulerType.h"
#import "RxSerialDisposable.h"
#import "RxScheduledDisposable.h"
#import "RxNopDisposable.h"

@interface RxSubscribeOnSink<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxSubscribeOnSink {
    RxSubscribeOn *__nonnull _parent;
}

- (nonnull instancetype)initWithParent:(nonnull RxSubscribeOn *)parent observer:(nonnull id <RxObserverType>)observer {
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

- (nonnull id <RxDisposable>)run {
    __block RxSerialDisposable *disposeEverything = [[RxSerialDisposable alloc] init];
    RxSingleAssignmentDisposable *cancelSchedule = [[RxSingleAssignmentDisposable alloc] init];
    
    disposeEverything.disposable = cancelSchedule;
    
    @weakify(self);
    cancelSchedule.disposable = [_parent->_scheduler schedule:nil action:^id <RxDisposable>(RxStateType __unused _) {
        @strongify(self);
        id <RxDisposable> subscription = [self->_parent->_source subscribe:self];
        disposeEverything.disposable = [[RxScheduledDisposable alloc] initWithScheduler:self->_parent->_scheduler
                                                                          andDisposable:subscription];

        return [RxNopDisposable sharedInstance];
    }];

    return disposeEverything;
}

@end

@implementation RxSubscribeOn

- (nonnull instancetype)initWithSource:(nonnull id<RxObservableType>)source
                             scheduler:(nonnull id <RxImmediateSchedulerType>)scheduler {
    self = [super init];
    if (self) {
        _scheduler = scheduler;
        _source = source;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxSubscribeOnSink *sink = [[RxSubscribeOnSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end