//
//  RxDeallocObservable
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RxReplaySubject<E>;

NS_ASSUME_NONNULL_BEGIN

@interface RxDeallocObservable : NSObject

@property (nonnull, strong, nonatomic, readonly) RxReplaySubject<id> *subject;

- (nonnull instancetype)init;

@end

NS_ASSUME_NONNULL_END