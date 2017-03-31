//
//  RxVariable
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservable.h"

NS_ASSUME_NONNULL_BEGIN

/**
Variable is a wrapper for `BehaviorSubject`.

Unlike `BehaviorSubject` it can't terminate with error, and when variable is deallocated
 it will complete it's observable sequence (`asObservable`).
*/
@interface RxVariable<Element> : NSObject

/**
Gets or sets current value of variable.

Whenever a new value is set, all the observers are notified of the change.

Even if the newly set value is same as the old value, observers are still notified for change.
*/
@property (nonnull, strong) Element value;

/**
Initializes variable with initial value.

- parameter value: Initial variable value.
*/
- (nonnull instancetype)initWithValue:(nonnull Element)value;

+ (nonnull instancetype)create:(nonnull Element)value;

/**
- returns: Canonical interface for push style sequence
*/
- (nonnull RxObservable<Element> *)asObservable;

@end

NS_ASSUME_NONNULL_END
