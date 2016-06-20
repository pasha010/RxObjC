//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable+RxBinding.h"
#import "RxSubjectType.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation NSObject (RxMulticast)

- (nonnull RxConnectableObservable<id <RxSubjectType>> *)multicast:(nonnull id <RxSubjectType>)subject {
    return [[RxConnectableObservableAdapter alloc] initWithSource:[self asObservable] andSubject:subject];
}

@end

@implementation NSObject (RxPublish)

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