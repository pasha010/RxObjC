//
//  RxBlockingObservable(Operators)
//  RxObjC
// 
//  Created by Pavel Malkov on 13.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxBlockingObservable.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxBlockingObservable (ToArray)
/**
 Blocks current thread until sequence terminates.

 If sequence terminates with error, terminating error will be thrown.

 - returns: All elements of sequence.
 */
- (nonnull NSArray *)blocking_toArray;

@end

@interface RxBlockingObservable (Last)
/**
 Blocks current thread until sequence terminates.

 If sequence terminates with error, terminating error will be thrown.

 - returns: Last element in the sequence. If sequence is empty `nil` is returned.
 */
- (nullable id)blocking_last;

@end

@interface RxBlockingObservable (Single)
/**
 Blocks current thread until sequence terminates.

 If sequence terminates with error before producing first element, terminating error will be thrown.

 - returns: Returns the only element of an sequence, and reports an error if there is not exactly one element in the observable sequence.
 */
- (nullable id)blocking_single;

/**
 Blocks current thread until sequence terminates.

 If sequence terminates with error before producing first element, terminating error will be thrown.

 - parameter predicate: A function to test each source element for a condition.
 - returns: Returns the only element of an sequence that satisfies the condition in the predicate, and reports an error if there is not exactly one element in the sequence.
 */
- (nullable id)blocking_single:(nonnull BOOL(^)(id __nullable))predicate;
@end

NS_ASSUME_NONNULL_END