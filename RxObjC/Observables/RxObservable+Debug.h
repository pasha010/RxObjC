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

@interface NSObject (RxDebug) <RxObservableType>
/**
 * Prints received events for all observers on standard output.
 * @see [do operator on reactivex.io](http://reactivex.io/documentation/operators/do.html)
 * @param identifier: Identifier that is printed together with event description to standard output.
 * @return: An observable sequence whose events are printed to standard output.
 */
- (nonnull RxObservable *)debug:(nullable NSString *)identifier;
- (nonnull RxObservable *)debug:(nullable NSString *)identifier file:(nonnull NSString *)file;
- (nonnull RxObservable *)debug:(nullable NSString *)identifier file:(nonnull NSString *)file line:(NSUInteger)line ;
- (nonnull RxObservable *)debug:(nullable NSString *)identifier file:(nonnull NSString *)file line:(NSUInteger)line function:(nonnull NSString *)function;
@end

NS_ASSUME_NONNULL_END