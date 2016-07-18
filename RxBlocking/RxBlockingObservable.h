//
//  RxBlockingObservable
//  RxObjC
// 
//  Created by Pavel Malkov on 13.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RxObjC/RxObjC.h>

NS_ASSUME_NONNULL_BEGIN

/**
`BlockingObservable` is a variety of `Observable` that provides blocking operators.

It can be useful for testing and demo purposes, but is generally inappropriate for production applications.

If you think you need to use a `BlockingObservable` this is usually a sign that you should rethink your
design.
*/
@interface RxBlockingObservable<E> : NSObject

@property (nonnull, nonatomic) RxObservable<E> *source;

- (nonnull instancetype)initWithSource:(nonnull RxObservable<E> *)source;

@end

NS_ASSUME_NONNULL_END