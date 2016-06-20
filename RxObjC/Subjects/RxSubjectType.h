//
// Created by Pavel Malkov on 20.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservableType.h"

NS_ASSUME_NONNULL_BEGIN

typedef id <RxObserverType> RxSubjectObserverType;

/**
Represents an object that is both an observable sequence as well as an observer.
*/
@protocol RxSubjectType <RxObservableType>

/**
Returns observer interface for subject.

- returns: Observer interface for subject.
*/
- (RxSubjectObserverType)asObserver;

@end

NS_ASSUME_NONNULL_END