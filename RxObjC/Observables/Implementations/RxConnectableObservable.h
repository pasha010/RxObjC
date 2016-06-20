//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservable.h"
#import "RxConnectableObservableType.h"
#import "RxSubjectType.h"
#import "RxLock.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Represents an observable wrapper that can be connected and disconnected from its underlying observable sequence.
*/
@interface RxConnectableObservable<Element> : RxObservable<Element> <RxConnectableObservableType>

/**
 Connects the observable wrapper to its source. All subscribed observers will receive values from the underlying observable sequence as long as the connection is established.

 - returns: Disposable used to disconnect the observable wrapper from its source, causing subscribed observer to stop receiving values from the underlying observable sequence.
*/
- (nonnull id <RxDisposable>)connect;

@end

@interface RxConnectableObservableAdapter<__covariant S : id <RxSubjectType>> : RxConnectableObservable<id>

- (nonnull instancetype)initWithSource:(nonnull RxObservable<id> *)source andSubject:(nonnull S)subject;

@end

NS_ASSUME_NONNULL_END