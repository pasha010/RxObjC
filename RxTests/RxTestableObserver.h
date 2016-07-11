//
//  RxTestableObserver
//  RxObjC
// 
//  Created by Pavel Malkov on 21.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxEvent.h"
#import "RxRecorded.h"
#import "RxObserverType.h"

@class RxTestScheduler;

NS_ASSUME_NONNULL_BEGIN

@interface RxTestableObserver<ElementType> : NSObject <RxObserverType>

@property (nonnull, strong, readonly) NSArray<RxRecorded<RxEvent<ElementType> *> *> *events;

- (nonnull instancetype)initWithTestScheduler:(nonnull RxTestScheduler *)testScheduler;

@end

NS_ASSUME_NONNULL_END