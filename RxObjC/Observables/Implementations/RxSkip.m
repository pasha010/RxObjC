//
//  RxSkip
//  RxObjC
// 
//  Created by Pavel Malkov on 02.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxSkip.h"
#import "RxSink.h"

@interface RxSkipCountSink<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxSkipCountSink {
    RxSkipCount *__nonnull _parent;
    NSInteger _remaining;
}

- (nonnull instancetype)initWithParent:(nonnull RxSkipCount *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _remaining = parent->_count;
        _parent = parent;
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    if (event.type == RxEventTypeNext) {
        if (_remaining <= 0) {
            [self forwardOn:[RxEvent next:event.element]];
        } else {
            _remaining--;
        }
    } else {
        [self forwardOn:event];
        [self dispose];
    }
}

@end

@implementation RxSkipCount

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source count:(NSInteger)count {
    self = [super init];
    if (self) {
        _source = source;
        _count = count;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxSkipCountSink *sink = [[RxSkipCountSink alloc] initWithParent:self observer:observer];
    sink.disposable = [_source subscribe:sink];
    return sink;
}

@end