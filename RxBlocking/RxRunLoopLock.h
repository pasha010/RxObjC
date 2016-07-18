//
//  RxRunLoopLock
//  RxObjC
// 
//  Created by Pavel Malkov on 13.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RxRunLoopLock : NSObject

- (nonnull instancetype)init;

- (void)dispatch:(nonnull void(^)())action;
- (void)stop;
- (void)run;

@end

NS_ASSUME_NONNULL_END