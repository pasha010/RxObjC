//
//  RxElementAt
//  RxObjC
// 
//  Created by Pavel Malkov on 04.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxElementAt.h"
#import "RxSink.h"
#import "RxObservable+Extension.h"
#import "RxError.h"

@interface RxElementAtSink<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxElementAtSink {
    RxElementAt *__nonnull _parent;
    NSUInteger _i;
}

- (nonnull instancetype)initWithParent:(nonnull RxElementAt *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
        _i = _parent->_index;
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    switch (event.type) {
        case RxEventTypeNext: {
            if (_i == 0) {
                [self forwardOn:event];
                [self forwardOn:[RxEvent completed]];
                [self dispose];
            }

            rx_tryCatch(^{
                rx_decrementCheckedUnsigned(&_i);
            }, ^(NSError *error) {
                [self forwardOn:[RxEvent error:error]];
                [self dispose];
            });
            break;
        }
        case RxEventTypeError: {
            [self forwardOn:event];
            [self dispose];
            break;
        }
        case RxEventTypeCompleted: {
            if (_parent->_throwOnEmpty) {
                [self forwardOn:[RxEvent error:[RxError argumentOutOfRange]]];
            } else {
                [self forwardOn:[RxEvent completed]];
            }
            [self dispose];
            break;
        }
    }
}

@end

@implementation RxElementAt

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source index:(NSUInteger)index throwOnEmpty:(BOOL)throwOnEmpty {
    self = [super init];
    if (self) {
        _source = source;
        _index = index;
        _throwOnEmpty = throwOnEmpty;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxElementAtSink *sink = [[RxElementAtSink alloc] initWithParent:self observer:observer];
    sink.disposable = [_source subscribeSafe:sink];
    return sink;
}

@end