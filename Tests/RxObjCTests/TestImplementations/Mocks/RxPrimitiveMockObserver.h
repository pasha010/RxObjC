//
//  RxPrimitiveMockObserver
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RxObjC/RxObserverType.h>
#import <RxTests/RxRecorded.h>
#import <RxObjC/RxEvent.h>

NS_ASSUME_NONNULL_BEGIN

@interface RxPrimitiveMockObserver : NSObject <RxObserverType>

@property (nonnull, readonly) NSArray<RxRecorded<RxEvent *> *> *events;

- (nonnull instancetype)init;

@end

NS_ASSUME_NONNULL_END