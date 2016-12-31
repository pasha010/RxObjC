//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable+Binding.h"
#import "RxMulticast.h"
#import "RxPublishSubject.h"
#import "RxReplaySubject.h"
#import "RxRefCount.h"
#import "RxShareReplay1.h"
#import "RxAnyObserver.h"
#import "RxShareReplay1WhileConnected.h"


@implementation RxObservable (Multicast)

- (nonnull RxConnectableObservable<id> *)multicast:(nonnull id <RxSubjectType>)subject {
    return [[RxConnectableObservableAdapter alloc] initWithSource:[self asObservable] andSubject:subject];
}

- (nonnull RxObservable<id> *)multicast:(RxSubjectSelectorType)subjectSelector selector:(RxSelectorType)sel {
    return [[RxMulticast alloc] initWithSource:[self asObservable] subjectSelector:subjectSelector selector:sel];
}

@end

@implementation RxObservable (Publish)

- (nonnull RxConnectableObservable<id> *)publish {
    return [self multicast:[RxPublishSubject create]];
}

@end

@implementation RxObservable (Replay)

- (nonnull RxConnectableObservable<id> *)replay:(NSUInteger)bufferSize {
    return [self multicast:[RxReplaySubject createWithBufferSize:bufferSize]];
}

- (nonnull RxConnectableObservable<id> *)replayAll {
    return [self multicast:[RxReplaySubject createUnbounded]];
}

@end

@implementation RxConnectableObservable (Refcount)

- (nonnull RxObservable<id> *)refCount {
    return [[RxRefCount alloc] initWithSource:self];
}
@end

@implementation RxObservable (Share)

- (nonnull RxObservable<id> *)share {
    return [[self publish] refCount];
}
@end

@implementation RxObservable (ShareReplay)

- (nonnull RxObservable<id> *)shareReplay:(NSUInteger)bufferSize {
    if (bufferSize == 1) {
        return [[RxShareReplay1 alloc] initWithSource:[self asObservable]];
    }
    return [[self replay:bufferSize] refCount];
}

- (nonnull RxObservable<id> *)shareReplayLatestWhileConnected {
    return [[RxShareReplay1WhileConnected alloc] initWithSource:[self asObservable]];
}

@end