//
//  RxRetryWhen
//  RxObjC
// 
//  Created by Pavel Malkov on 28.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxRetryWhenSequence<__covariant S : NSEnumerator *> : RxProducer<id> {
@package
    id <RxObservableType> (^_notificationHandler)(RxObservable<NSError *> *);
}

- (nonnull instancetype)initWithSources:(S)sequence
                    notificationHandler:(id <RxObservableType> (^)(RxObservable<NSError *> *))handler;

@end

NS_ASSUME_NONNULL_END