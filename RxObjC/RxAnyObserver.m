//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxAnyObserver.h"
#import "RxObservable.h"
#import "RxDisposable.h"
#import "RxTuple.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
@implementation RxAnyObserver

- (nonnull instancetype)initWithObserver:(nonnull id <RxObserverType>)observer {
    return [self initWithEventHandler:^(RxEvent *event) {
        [observer on:event];
    }];
}

- (nonnull instancetype)initWithEventHandler:(RxEventHandler)eventHandler {
    self = [super init];
    if (self) {
        _observer = [eventHandler copy];
    }

    return self;
}

/**
Send `event` to this observer.

- parameter event: Event instance.
*/
- (void)on:(nonnull RxEvent *)event {
    self.observer(event);
}

- (nonnull RxAnyObserver<id> *)asObserver {
    return self;
}

@end

#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation NSObject (RxAnyObserver)

- (nonnull RxAnyObserver<id> *)asObserver {
    return [[RxAnyObserver alloc] initWithObserver:self];
}

@end
#pragma clang diagnostic pop