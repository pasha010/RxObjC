//
//  RxTarget
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RxObjC/RxObjC.h>

NS_ASSUME_NONNULL_BEGIN

@interface RxTarget : NSObject <RxDisposable>

- (nonnull instancetype)init;

@end

NS_ASSUME_NONNULL_END