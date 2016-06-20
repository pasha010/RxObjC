//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxScheduledItem.h"
#import "RxSingleAssignmentDisposable.h"


@implementation RxScheduledItem {
    id <RxDisposable> (^_action)(id);
    id __nonnull _state;
    RxSingleAssignmentDisposable *__nonnull _disposable;
}

- (nonnull instancetype)initWithAction:(nonnull id <RxDisposable>(^)(id))action andState:(nonnull id)state {
    self = [super init];
    if (self) {
        _disposable = [[RxSingleAssignmentDisposable alloc] init];
        _action = action;
        _state = state;
    }
    return self;
}

- (void)invoke {
    _disposable.disposable = _action(_state);
}

- (BOOL)disposed {
    return _disposable.disposed;
}

- (void)dispose {
    [_disposable dispose];
}


@end