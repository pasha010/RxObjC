//
//  RxRecorded.h
//  RxObjC
//
//  Created by Pavel Malkov on 21.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxTestsDefTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxRecorded<ObjectType> : NSObject

/**
Gets the virtual time the value was produced on.
*/
@property (assign, nonatomic, readonly) RxTestTime time;
/**
Gets the recorded value.
*/
@property (nonnull, strong, nonatomic, readonly) ObjectType value;

- (instancetype)initWithTime:(RxTestTime)time value:(nonnull ObjectType)value;

@end

NS_ASSUME_NONNULL_END