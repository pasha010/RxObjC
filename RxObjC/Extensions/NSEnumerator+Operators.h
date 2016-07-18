//
//  NSEnumerator(Operators)
//  RxObjC
// 
//  Created by Pavel Malkov on 16.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservableBlockTypedef.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSNumber *__nonnull(^RxEnumeratorCombineOperator)(NSNumber *__nonnull initial, NSNumber *__nonnull element);

FOUNDATION_EXTERN RxEnumeratorCombineOperator RxCombinePlus();
FOUNDATION_EXTERN RxEnumeratorCombineOperator RxCombineDiff();
FOUNDATION_EXTERN RxEnumeratorCombineOperator RxCombineMult();
FOUNDATION_EXTERN RxEnumeratorCombineOperator RxCombineDiv();

FOUNDATION_EXTERN RxMapSelector RxReturnSelf();

@interface NSEnumerator<E> (Combine)

- (nonnull E)reduce:(nonnull E)start combine:(E(^)(E __nonnull initial, E __nonnull element))combine;

@end

NS_ASSUME_NONNULL_END