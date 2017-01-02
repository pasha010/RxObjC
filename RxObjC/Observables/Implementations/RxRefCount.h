//
//  RxRefCount
//  RxObjC
// 
//  Created by Pavel Malkov on 23.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

@class RxConnectableObservable;

NS_ASSUME_NONNULL_BEGIN

@interface RxRefCount<__covariant CO : RxConnectableObservable *> : RxProducer {
@package
    NSRecursiveLock *__nonnull _lock;
    NSUInteger _count;
    id<RxDisposable> __nullable _connectableSubscription;
    CO __nonnull _source;
}

- (nonnull instancetype)initWithSource:(nonnull CO)source;

@end

NS_ASSUME_NONNULL_END