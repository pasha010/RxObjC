//
//  RxObservable(Debug)
//  RxObjC
// 
//  Created by Pavel Malkov on 26.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable+Debug.h"
#import "RxSink.h"
#import "RxProducer.h"

static NSUInteger const kMaxEventTextLength = 40;

@interface RxDebugProducer<Element> : RxProducer<Element>

@property (nonnull, nonatomic, strong, readonly) RxObservable<Element> *source;
@property (nonnull, nonatomic, strong, readonly) NSString *identifier;

- (nonnull instancetype)initWithSource:(nonnull RxObservable<Element> *)source
                            identifier:(nonnull NSString *)identifier;

@end

@implementation RxObservable (Debug)

- (nonnull RxObservable *)debug:(nonnull NSString *)identifier {
    return [[RxDebugProducer alloc] initWithSource:[self asObservable]
                                        identifier:identifier];
}
@end

#pragma mark - private implementation

void logEvent(NSString *identifier, NSString *content) {
    NSLog(@"%@ -> %@", identifier, content);
}

@interface RxDebugProducerSink<O : id<RxObserverType>> : RxSink<O> <RxObserverType>
@end

@implementation RxDebugProducerSink {
    RxDebugProducer *__nonnull _parent;
}

- (nonnull instancetype)initWithParent:(nonnull RxDebugProducer *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
        logEvent(_parent.identifier, @"subscribed");
    }
    return self;
}

- (void)on:(nonnull RxEvent *)event {
    NSString *eventText = [event debugDescription];
    NSString *eventNormalized = eventText;
    if (eventNormalized.length > kMaxEventTextLength) {
        eventNormalized = [NSString stringWithFormat:@"%@...%@", [eventText substringToIndex:kMaxEventTextLength / 2], [eventText substringFromIndex:kMaxEventTextLength / 2]];
    }
    logEvent(_parent.identifier, [NSString stringWithFormat:@"Event %@", eventNormalized]);
    [self forwardOn:event];
}

- (void)dispose {
    logEvent(_parent.identifier, @"disposed");
    [super dispose];
}

@end

@implementation RxDebugProducer

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source
                            identifier:(nonnull NSString *)identifier {
    self = [super init];
    if (self) {
        _source = source;
        _identifier = identifier;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxDebugProducerSink *sink = [[RxDebugProducerSink alloc] initWithParent:self observer:observer];
    sink.disposable = [_source subscribe:sink];
    return sink;
}

@end