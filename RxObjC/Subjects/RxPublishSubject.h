//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservable.h"
#import "RxSubjectType.h"
#import "RxSynchronizedUnsubscribeType.h"
#import "RxCancelable.h"
#import "RxObservable+Extension.h"

NS_ASSUME_NONNULL_BEGIN

/**
Represents an object that is both an observable sequence as well as an observer.

Each notification is broadcasted to all subscribed observers.
*/
@interface RxPublishSubject<Element> : RxObservable<Element> <RxSubjectType, RxCancelable, RxObserverType, RxSynchronizedUnsubscribeType>

/**
 Indicates whether the subject has any observers
 */
@property (assign, atomic, readonly) BOOL hasObservers;

/**
Creates a subject.
*/
+ (nonnull instancetype)create;

/**
Creates a subject.
*/
- (nonnull instancetype)init NS_DESIGNATED_INITIALIZER;

/**
Indicates whether the subject has been disposed.
*/
- (BOOL)disposed;

/**
Notifies all subscribed observers about next event.

- parameter event: Event to send to the observers.
*/
- (void)on:(nonnull RxEvent<id> *)event;

/**
Subscribes an observer to the subject.

- parameter observer: Observer to subscribe to the subject.
- returns: Disposable object that can be used to unsubscribe the observer from the subject.
*/
- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer;

/**
Returns observer interface for subject.
*/
- (nonnull instancetype)asObserver;

/**
Unsubscribe all observers and release resources.
*/
- (void)dispose;

@end

NS_ASSUME_NONNULL_END