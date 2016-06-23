//
//  RxReplaySubject
//  RxObjC
// 
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservable.h"
#import "RxSubjectType.h"
#import "RxLock.h"
#import "RxBag.h"

@class RxAnyObserver;

NS_ASSUME_NONNULL_BEGIN

/**
Represents an object that is both an observable sequence as well as an observer.

Each notification is broadcasted to all subscribed and future observers, subject to buffer trimming policies.
*/
@interface RxReplaySubject<Element> : RxObservable<Element> <RxSubjectType, RxObserverType, RxDisposable> {
@package
    RxSpinLock *__nonnull _lock;
    BOOL _disposed;
    RxEvent *__nullable _stoppedEvent;
    RxBag<RxAnyObserver *> *__nonnull _observers;

}

@property (assign, readonly) BOOL hasObservers;

/**
Creates new instance of `ReplaySubject` that replays at most `bufferSize` last elements of sequence.

- parameter bufferSize: Maximal number of elements to replay to observer after subscription.
- returns: New instance of replay subject.
*/
+ (nonnull instancetype)createWithBufferSize:(NSUInteger)bufferSize;

/**
Creates a new instance of `ReplaySubject` that buffers all the elements of a sequence.
To avoid filling up memory, developer needs to make sure that the use case will only ever store a 'reasonable'
number of elements.
*/
+ (nonnull instancetype)createUnbounded;


@end

NS_ASSUME_NONNULL_END