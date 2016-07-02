//
//  RxTake
//  RxObjC
// 
//  Created by Pavel Malkov on 02.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTake.h"
#import "RxSink.h"

@interface RxTakeCountSink<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxTakeCountSink {
    RxTakeCount *__nonnull _parent;
    NSUInteger _remaining;
}

- (nonnull instancetype)initWithParent:(nonnull RxTakeCount *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _remaining = _parent->_count;
        _parent = parent;
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    if (event.type == RxEventTypeNext) {
        if (_remaining > 0) {
            _remaining--;
            [self forwardOn:[RxEvent next:event.element]];

            if (_remaining == 0) {
                [self forwardOn:[RxEvent completed]];
                [self dispose];
            }
        }
    } else {
        [self forwardOn:event];
        [self dispose];
    }
}

@end

@implementation RxTakeCount

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source count:(NSUInteger)count {
    self = [super init];
    if (self) {
        _source = source;
        _count = count;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxTakeCountSink *sink = [[RxTakeCountSink alloc] initWithParent:self observer:observer];
    sink.disposable = [_source subscribe:sink];
    return sink;
}

@end