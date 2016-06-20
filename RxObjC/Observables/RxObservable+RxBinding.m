//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable+RxBinding.h"
#import "RxSubjectType.h"
#import "RxMulticast.h"
#import "RxPublishSubject.h"


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

@end

@implementation NSObject (RxRefcount)

@end

@implementation NSObject (RxShare)

@end

@implementation NSObject (RxShareReplay)

@end
#pragma clang diagnostic pop