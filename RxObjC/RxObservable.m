//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable.h"
#import "RxObjC.h"
#import "RxAnonymousObserver.h"
#import "RxAnonymousDisposable.h"
#import "RxNopDisposable.h"
#import "RxBinaryDisposable.h"
#import "RxMap.h"

@implementation RxObservable

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
#if TRACE_RESOURCES
        OSAtomicIncrement32(&rx_resourceCount);
#endif
    }
    return self;
}

- (void)dealloc {
#if TRACE_RESOURCES
    OSAtomicDecrement32(&rx_resourceCount);
#endif
}


- (id <RxDisposable>)subscribe:(id <RxObserverType>)observer {
    return rx_abstractMethod();
}

- (nonnull RxObservable *)asObservable {
    return self;
}

- (nonnull RxObservable *)_composeMap:(nonnull RxMapSelector)mapSelector {
    return [[RxMap alloc] initWithSource:self selector:mapSelector];
}


@end