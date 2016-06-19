//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObserverType.h"

@interface NSObject (RxObserverType) <RxObserverType>

/**
Convenience method equivalent to `on(.Next(element: E))`

- parameter element: Next element to send to observer(s)
*/
- (void)onNext:(nullable id)element;

/**
Convenience method equivalent to `on(.Completed)`
*/
- (void)onCompleted;

/**
Convenience method equivalent to `on(.Error(error: ErrorType))`
- parameter error: ErrorType to send to observer(s)
*/
- (void)onError:(nullable NSError *)error;

@end