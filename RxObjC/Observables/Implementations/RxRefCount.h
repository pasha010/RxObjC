//
//  RxRefCount
//  RxObjC
// 
//  Created by Pavel Malkov on 23.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

@protocol RxConnectableObservableType;

NS_ASSUME_NONNULL_BEGIN

@interface RxRefCount<CO : id <RxConnectableObservableType>> : RxProducer {
@package
    NSRecursiveLock *__nonnull _lock;
    NSUInteger _count;
    id<RxDisposable> __nullable _connectableSubscription;
    id <RxConnectableObservableType> __nonnull _source;
}

- (nonnull instancetype)initWithSource:(nonnull CO)source;

@end

NS_ASSUME_NONNULL_END