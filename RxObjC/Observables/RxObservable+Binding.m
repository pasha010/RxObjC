//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable+Binding.h"
#import "RxSubjectType.h"
#import "RxMulticast.h"
#import "RxPublishSubject.h"
#import "RxReplaySubject.h"
#import "RxRefCount.h"
#import "RxShareReplay1.h"
#import "RxAnyObserver.h"
#import "RxShareReplay1WhileConnected.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma GCC diagnostic ignored "-Wprotocol"

@implementation NSObject (RxMulticast)

- (nonnull RxConnectableObservable<id <RxSubjectType>> *)multicast:(nonnull id <RxSubjectType>)subject {
    return [[RxConnectableObservableAdapter alloc] initWithSource:[self asObservable] andSubject:subject];
}

- (nonnull RxObservable<id> *)multicast:(RxSubjectSelectorType)subjectSelector selector:(RxSelectorType)sel {
    return [[RxMulticast alloc] initWithSource:[self asObservable] subjectSelector:subjectSelector selector:sel];
}

@end

@implementation NSObject (RxPublish)

- (nonnull RxConnectableObservable<RxPublishSubject *> *)publish {
    RxConnectableObservable<RxPublishSubject *> *r = (RxConnectableObservable<RxPublishSubject *> *) [self multicast:[RxPublishSubject create]];
    return r;
}

@end

@implementation NSObject (RxReplay)

- (nonnull RxConnectableObservable<RxReplaySubject *> *)replay:(NSUInteger)bufferSize {
    RxConnectableObservable<RxReplaySubject *> *r = (RxConnectableObservable<RxReplaySubject *> *) [self multicast:[RxReplaySubject createWithBufferSize:bufferSize]];
    return r;
}

- (nonnull RxConnectableObservable<RxReplaySubject *> *)replayAll {
    RxConnectableObservable<RxReplaySubject *> *r = (RxConnectableObservable<RxReplaySubject *> *) [self multicast:[RxReplaySubject createUnbounded]];
    return r;
}

@end

@implementation NSObject (RxRefcount)

- (nonnull RxObservable *)refCount {
    return [[RxRefCount alloc] initWithSource:self];
}
@end

@implementation NSObject (RxShare)

- (nonnull RxObservable *)share {
    return [[self publish] refCount];
}
@end

@implementation NSObject (RxShareReplay)

- (nonnull RxObservable *)shareReplay:(NSUInteger)bufferSize {
    if (bufferSize == 1) {
        return [[RxShareReplay1 alloc] initWithSource:[self asObservable]];
    }
    return [[self replay:bufferSize] refCount];
}

- (nonnull RxObservable *)shareReplayLatestWhileConnected {
    return [[RxShareReplay1WhileConnected alloc] initWithSource:[self asObservable]];
}

@end
#pragma clang diagnostic pop