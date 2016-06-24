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
#import "RxShareReplay1.h"


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
    /*
     * if bufferSize == 1 {
            return ShareReplay1(source: self.asObservable())
        }
        else {
            return self.replay(bufferSize).refCount()
        }
     */
}

@end
#pragma clang diagnostic pop