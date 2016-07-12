//
//  RxUsing
//  RxObjC
// 
//  Created by Pavel Malkov on 25.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxUsing.h"


#import "RxSink.h"
#import "RxNopDisposable.h"
#import "RxStableCompositeDisposable.h"
#import "RxObservable+Creation.h"

@interface RxUsingSink<O : id<RxObserverType>> : RxSink<O>
@end

@implementation RxUsingSink {
    RxUsing *__nonnull _parent;
}

- (nonnull instancetype)initWithParent:(nonnull RxUsing *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
    }
    return self;
}

- (nonnull id <RxDisposable>)run {
    __block id <RxDisposable> disposable = [RxNopDisposable sharedInstance];

    __block id <RxDisposable> res = nil;

    rx_tryCatch(self, ^{
        id <RxDisposable> resource = _parent->_resourceFactory();
        disposable = resource;

        RxObservable *source = _parent->_observableFactory(resource);

        res = [RxStableCompositeDisposable createDisposable1:[source subscribe:self] disposable2:disposable];
    }, ^(NSError *error) {
        res = [RxStableCompositeDisposable createDisposable1:[[RxObservable error:error] subscribe:self]
                                                 disposable2:disposable];
    });

    return res;
}

@end

@implementation RxUsing

- (nonnull instancetype)initWithResourceFactory:(RxUsingResourceFactory)resourceFactory 
                              observableFactory:(RxUsingObservableFactory)observableFactory {
    self = [super init];
    if (self) {
        _resourceFactory = resourceFactory;
        _observableFactory = observableFactory;
    }
    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    RxUsingSink *sink = [[RxUsingSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end