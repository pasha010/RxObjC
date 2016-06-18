//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservableConvertibleType.h"

@protocol RxDisposable;
@protocol RxObserverType;

/**
 * Represents a push style sequence.
*/
@protocol RxObservableType <RxObservableConvertibleType>

/**
    Subscribes `observer` to receive events for this sequence.

    ### Grammar

    **Next\* (Error | Completed)?**

    * sequences can produce zero or more elements so zero or more `Next` events can be sent to `observer`
    * once an `Error` or `Completed` event is sent, the sequence terminates and can't produce any other elements

    It is possible that events are sent from different threads, but no two events can be sent concurrently to
    `observer`.

    ### Resource Management

    When sequence sends `Complete` or `Error` event all internal resources that compute sequence elements
    will be freed.

    To cancel production of sequence elements and free resources immediatelly, call `dispose` on returned
    subscription.

    - returns: Subscription for `observer` that can be used to cancel production of sequence elements and free resources.
    */

- (id <RxDisposable>)subscribe:(id <RxObserverType>)observer;

@end