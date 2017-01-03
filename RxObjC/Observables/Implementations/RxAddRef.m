//
//  RxAddRef
//  RxObjC
// 
//  Created by Pavel Malkov on 09.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxAddRef.h"
#import "RxSink.h"
#import "RxRefCountDisposable.h"
#import "RxStableCompositeDisposable.h"
#import "RxObservable+Extension.h"


@interface RxAddRefSink<O : id<RxObserverType>> : RxSink<O> <RxObserverType>
@end

@implementation RxAddRefSink

- (void)on:(nonnull RxEvent *)event {
    [self forwardOn:event];
    if (event.type != RxEventTypeNext) {
        [self dispose];
    }
}

@end

@implementation RxAddRef

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source
                              refCount:(nonnull RxRefCountDisposable *)refCount {
    self = [super init];
    if (self) {
        _source = source;
        _refCount = refCount;
    }

    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    id <RxDisposable> releaseDisposable = [_refCount rx_retain];
    RxAddRefSink *sink = [[RxAddRefSink alloc] initWithObserver:observer];
    sink.disposable = [RxStableCompositeDisposable createDisposable1:releaseDisposable disposable2:[_source subscribeSafe:sink]];

    return sink;
}

@end