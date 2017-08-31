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

@interface RxBlockingObservable<E> (ToArray)
/**
 * Blocks current thread until sequence terminates.
 * If sequence terminates with error, terminating error will be thrown.
 * @return All elements of sequence.
 */
- (nonnull NSArray<E> *)toArray;

@end

@interface RxBlockingObservable<E> (First)
/**
 * Blocks current thread until sequence produces first element.
 * If sequence terminates with error before producing first element, terminating error will be thrown.
 * @return First element of sequence. If sequence is empty `nil` is returned.
 */
@property (nullable, readonly) E first;

@end

@interface RxBlockingObservable<E> (Last)
/**
 * Blocks current thread until sequence terminates.
 * If sequence terminates with error, terminating error will be thrown.
 * @return Last element in the sequence. If sequence is empty `nil` is returned.
 */
@property (nullable, readonly) E last;

@end

@interface RxBlockingObservable<E> (Single)
/**
 * Blocks current thread until sequence terminates.
 * If sequence terminates with error before producing first element, terminating error will be thrown.
 * @return Returns the only element of an sequence, and reports an error if there is not exactly one element in the observable sequence.
 */
@property (nullable, readonly) E single;


/**
 * Blocks current thread until sequence terminates.
 * If sequence terminates with error before producing first element, terminating error will be thrown.
 * @param predicate: A function to test each source element for a condition.
 * @return Returns the only element of an sequence that satisfies the condition in the predicate,
 *          and reports an error if there is not exactly one element in the sequence.
 */
- (nullable E)singleWithPredicate:(BOOL(^_Nonnull)(E __nullable))predicate;
@end

NS_ASSUME_NONNULL_END