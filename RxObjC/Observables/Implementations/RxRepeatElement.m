//
//  RxRepeatElement
//  RxObjC
// 
//  Created by Pavel Malkov on 25.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxRepeatElement.h"
#import "RxImmediateSchedulerType.h"
#import "RxSink.h"

@interface RxRepeatElementSink<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxRepeatElementSink {
    RxRepeatElement *__nonnull _parent;
}

- (nonnull instancetype)initWithParent:(nonnull RxRepeatElement *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
    }
    return self;
}

- (nonnull id <RxDisposable>)run {
    NSObject <RxImmediateSchedulerType> *scheduler = _parent->_scheduler;
    @weakify(self);
    return [scheduler scheduleRecursive:_parent->_element action:^(id e, void (^recurse)(id)) {
        @strongify(self);
        [self forwardOn:[RxEvent next:e]];
        recurse(e);
    }];
}

@end

@implementation RxRepeatElement

- (nonnull instancetype)initWithElement:(nonnull id)element scheduler:(nonnull id <RxImmediateSchedulerType>)scheduler {
    self = [super init];
    if (self) {
        _element = element;
        _scheduler = scheduler;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxRepeatElementSink *sink = [[RxRepeatElementSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end