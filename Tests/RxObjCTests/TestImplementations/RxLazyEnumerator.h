//
//  RxLazyEnumerator
//  RxObjC
// 
//  Created by Pavel Malkov on 16.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef id __nonnull(^RxLazyEnumeratorBlock)();

@interface RxLazyEnumerator<T> : NSEnumerator<T>

- (nonnull instancetype)initWithObjects:(nonnull NSArray<RxLazyEnumeratorBlock> *)lazyObjects;

@end

NS_ASSUME_NONNULL_END