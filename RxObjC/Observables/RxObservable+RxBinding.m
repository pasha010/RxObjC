//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable+RxBinding.h"
#import "RxSubjectType.h"
#import "RxMulticast.h"
#import "RxPublishSubject.h"
#import "RxReplaySubject.h"
#import "RxRefCount.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation NSObject (RxMulticast)

- (nonnull RxConnectableObservable<id <RxSubjectType>> *)multicast:(nonnull id <RxSubjectType>)subject {
    return [[RxConnectableObservableAdapter alloc] initWithSource:[self asObservable] andSubject:subject];
}

- (nonnull RxObservable<id> *)multicast:(RxSubjectSelectorType)subjectSelector selector:(RxSelectorType)sel {
    return [[RxMulticast alloc] initWithSource:[self asObservable] subjectSelector:subjectSelector selector:sel];
}

@end

@implementation NSObject (RxPublish)

- (nonnull RxConnectableObservable<id> *)publish {
    return [self multicast:[RxPublishSubject create]];
}

@end

@implementation NSObject (RxReplay)

- (nonnull RxConnectableObservable<id> *)replay:(NSUInteger)bufferSize {
    return [self multicast:[RxReplaySubject createWithBufferSize:bufferSize]];
}

- (nonnull RxConnectableObservable<id> *)replayAll {
    return [self multicast:[RxReplaySubject createUnbounded]];
}

@end

@implementation NSObject (RxRefcount)

- (nonnull RxObservable *)refCount {
    return [[RxRefCount alloc] initWithSource:self];
}
@end

@implementation NSObject (RxShare)

@end

@implementation NSObject (RxShareReplay)

@end
#pragma clang diagnostic pop