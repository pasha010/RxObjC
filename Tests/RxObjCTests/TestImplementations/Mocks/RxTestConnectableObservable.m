//
//  RxTestConnectableObservable
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxTestConnectableObservable.h"
#import "RxConnectableObservable.h"
#import "RxObservable+Binding.h"
#import "RxObservable+Creation.h"
#import "RxAnyObserver.h"

@implementation RxTestConnectableObservable {
    RxConnectableObservable *__nonnull _o;
}

- (nonnull instancetype)initWithObservable:(nonnull RxObservable *)observable subject:(nonnull id <RxSubjectType>)subject {
    self = [super init];
    if (self) {
        _o = [observable multicast:subject];
    }
    return self;
}

- (nonnull id <RxDisposable>)connect {
    return [_o connect];
}

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    return [_o subscribe:observer];
}

- (nonnull RxObservable *)asObservable {
    return [RxObservable create:^id <RxDisposable>(RxAnyObserver *observer) {
        return [self subscribe:observer];
    }];
}

@end