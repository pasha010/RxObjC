//
//  RxJust
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxJust.h"
#import "RxNopDisposable.h"
#import "RxImmediateSchedulerType.h"
#import "RxSink.h"

@interface RxJustScheduledSink<O : id <RxObserverType>> : RxSink<O>
@end

@implementation RxJustScheduledSink {
    RxJustScheduled *__nonnull _parent;
}

- (nonnull instancetype)initWithParent:(nonnull RxJustScheduled *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
    }
    return self;
}

- (nonnull id <RxDisposable>)run {
    return [_parent->_scheduler schedule:_parent->_element action:^id <RxDisposable>(RxStateType element) {
        [self forwardOn:[RxEvent next:element]];
        return [self->_parent->_scheduler schedule:nil action:^id <RxDisposable>(RxStateType _) {
            [self forwardOn:[RxEvent completed]];
            return [RxNopDisposable sharedInstance];
        }];
    }];
}

@end

@implementation RxJustScheduled

- (instancetype)initWithElement:(nullable id)element scheduler:(nonnull id <RxImmediateSchedulerType>)scheduler {
    self = [super init];
    if (self) {
        _element = element;
        _scheduler = scheduler;
    }
    return self;
}

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    RxJustScheduledSink *sink = [[RxJustScheduledSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end

@implementation RxJust {
    id __nonnull _element;
}

- (nonnull instancetype)initWithElement:(nullable id)element {
    self = [super init];
    if (self) {
        _element = element;
    }
    return self;
}

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    [observer on:[RxEvent next:_element]];
    [observer on:[RxEvent completed]];
    return [RxNopDisposable sharedInstance];
}


@end