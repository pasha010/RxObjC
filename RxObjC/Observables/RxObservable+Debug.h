//
//  RxObservable(Debug)
//  RxObjC
// 
//  Created by Pavel Malkov on 26.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservable.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxObservable<E> (Debug)

/**
 * Prints received events for all observers on standard output.
 * @see [do operator on reactivex.io](http://reactivex.io/documentation/operators/do.html)
 * @param identifier Identifier that is printed together with event description to standard output.
 * @return An observable sequence whose events are printed to standard output.
 */
- (nonnull instancetype)debug:(nonnull NSString *)identifier;

@end

NS_ASSUME_NONNULL_END