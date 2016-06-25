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
    RxNopDisposable *disposable = [RxNopDisposable sharedInstance];

    @try {
        id <RxDisposable> resource = _parent->_resourceFactory();
        disposable = resource;

        RxObservable *source = _parent->_observableFactory(resource);

        return [RxStableCompositeDisposable createDisposable1:[source subscribe:self] disposable2:disposable];
    }
    @catch (id e) {
        NSError *error = e;
        if ([e isKindOfClass:[NSException class]]) {
            NSException *exception = e;
            error = [NSError errorWithDomain:[NSString stringWithFormat:@"RxUsingSink + %@", exception.name]
                                        code:[self hash]
                                    userInfo:exception.userInfo];
        }
        return [RxStableCompositeDisposable createDisposable1:[[RxObservable error:error] subscribe:self]
                                                  disposable2:disposable];
    }
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