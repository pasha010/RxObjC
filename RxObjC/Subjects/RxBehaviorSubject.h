//
//  RxBehaviorSubject
//  RxObjC
// 
//  Created by Pavel Malkov on 09.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxSubjectType.h"
#import "RxObservable.h"
#import "RxSynchronizedUnsubscribeType.h"

NS_ASSUME_NONNULL_BEGIN

/**
Represents a value that changes over time.

Observers can subscribe to the subject to receive the last (or initial) value and all subsequent notifications.
*/
@interface RxBehaviorSubject<Element> : RxObservable<Element> <RxSubjectType, RxObserverType, RxSynchronizedUnsubscribeType, RxDisposable>

/**
Gets the current value or throws an error.

- returns: Latest value.
*/
@property (nonnull, strong, readonly) Element value;

/**
 Indicates whether the subject has any observers
 */
@property (readonly) BOOL hasObservers;

/**
Indicates whether the subject has been disposed.
*/
@property (readonly) BOOL disposed;

/**
Initializes a new instance of the subject that caches its last value and starts with the specified value.

- parameter value: Initial value sent to observers when no other value has been received by the subject yet.
*/
- (nonnull instancetype)initWithValue:(nonnull Element)value;

+ (nonnull instancetype)create:(nonnull Element)value;

/**
Notifies all subscribed observers about next event.

- parameter event: Event to send to the observers.
*/
- (void)on:(nonnull RxEvent<Element> *)event;

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