//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObserverType.h"

NS_ASSUME_NONNULL_BEGIN

/**
A type-erased `ObserverType`.

Forwards operations to an arbitrary underlying observer with the same `Element` type, hiding the specifics of the underlying observer type.
*/

@interface RxAnyObserver<__covariant Element> : NSObject <RxObserverType>

@property (copy, nonatomic) RxEventHandler observer;

/**
Construct an instance whose `on(event)` calls `observer.on(event)`

- parameter observer: Observer that receives sequence events.
*/
- (nonnull instancetype)initWithObserverEvent:(nonnull id <RxObserverType>)observer;

/**
Construct an instance whose `on(event)` calls `eventHandler(event)`

- parameter eventHandler: Event handler that observes sequences events.
*/
- (nonnull instancetype)initWithEventHandler:(RxEventHandler)eventHandler NS_DESIGNATED_INITIALIZER;

/**
 Erases type of observer and returns canonical observer.

 - returns: type erased observer.
 */
- (nonnull RxAnyObserver<Element> *)asObserver;

@end

@interface NSObject (RxAnyObserver) <RxObserverType>

- (nonnull RxAnyObserver<id> *)asObserver;

@end

NS_ASSUME_NONNULL_END