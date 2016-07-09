//
//  RxDebugProducer
//  RxObjC
// 
//  Created by Pavel Malkov on 09.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxDebugProducer.h"
#import "RxSink.h"

void rx_logEvent(NSString *identifier, NSString *content) {
    NSLog(@"%@ -> %@", identifier, content);
}

@interface RxDebugProducerSink<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxDebugProducerSink {
    RxDebugProducer *__nonnull _parent;
}

- (nonnull instancetype)initWithParent:(nonnull RxDebugProducer *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
        rx_logEvent(_parent->_identifier, @"subscribed");

    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    NSUInteger maxEventTextLength = 40;
    NSString *eventText = [event debugDescription];
    NSString *eventNormalized = eventText;
    if (eventNormalized.length > maxEventTextLength) {
        eventNormalized = [NSString stringWithFormat:@"%@...%@", [eventText substringToIndex:maxEventTextLength / 2], [eventText substringFromIndex:maxEventTextLength / 2]];
    }
    rx_logEvent(_parent->_identifier, [NSString stringWithFormat:@"Event %@", eventNormalized]);
    [self forwardOn:event];
}

- (void)dispose {
    rx_logEvent(_parent->_identifier, @"disposed");
    [super dispose];
}

@end

@implementation RxDebugProducer

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source
                            identifier:(nullable NSString *)identifier
                                  file:(nonnull NSString *)file
                                  line:(nonnull NSString *)line
                              function:(nonnull NSString *)function {
    self = [super init];
    if (self) {
        _source = source;
        if (identifier) {
            _identifier = identifier;
        } else {
            NSString *trimmedFile;
            NSUInteger lastIndex = [file rangeOfString:@"/" options:NSBackwardsSearch].location;
            if (lastIndex != 0) {
                trimmedFile = [file substringFromIndex:lastIndex];
            } else {
                trimmedFile = file;
            }
            _identifier = [NSString stringWithFormat:@"(%@): (%@) (%@)", trimmedFile, line, function];
        }
    }

    return self;
}


- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxDebugProducerSink *sink = [[RxDebugProducerSink alloc] initWithParent:self observer:observer];
    sink.disposable = [_source subscribe:sink];
    return sink;
}

@end