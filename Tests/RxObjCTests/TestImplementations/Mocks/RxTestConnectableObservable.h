//
//  RxTestConnectableObservable
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxSubjectType.h"
#import "RxConnectableObservableType.h"

@class RxConnectableObservable<S>;

NS_ASSUME_NONNULL_BEGIN

@interface RxTestConnectableObservable<S : id <RxSubjectType>> : NSObject <RxConnectableObservableType>

- (nonnull instancetype)initWithObservable:(nonnull RxObservable *)observable subject:(nonnull S)subject;

@end

NS_ASSUME_NONNULL_END