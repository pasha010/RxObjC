//
//  NSEnumerator(Operators)
//  RxObjC
// 
//  Created by Pavel Malkov on 16.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSNumber *__nonnull(^NSEnumeratorCombinePlus)(NSNumber *__nonnull initial, NSNumber *__nonnull element);

FOUNDATION_EXTERN NSEnumeratorCombinePlus NSCombinePlus();

@interface NSEnumerator<E> (Combine)

- (nonnull E)reduce:(nonnull E)start combine:(E(^)(E __nonnull initial, E __nonnull element))combine;

@end

NS_ASSUME_NONNULL_END