//
//  RxTestableObservable.h
//  RxObjC
// 
//  Created by Pavel Malkov on 21.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObservableType.h"
#import "RxRecorded.h"

@class RxSubscription;
@class RxTestScheduler;

NS_ASSUME_NONNULL_BEGIN

@interface RxTestableObservable<Element> : NSObject <RxObservableType>

/**
 Subscriptions recorded during observable lifetime.
*/
@property (nonnull, strong, readonly) NSMutableArray<RxSubscription *> *subscriptions;

@property (nonnull, strong, readonly) RxTestScheduler *testScheduler;

/**
 List of events to replay for all subscribers.

 Event times represent absolute `TestScheduler` time.
*/
@property (nonnull, strong) NSArray<RxRecorded<RxEvent<Element> *> *> *recordedEvents;

- (nonnull instancetype)initWithTestScheduler:(nonnull RxTestScheduler *)testScheduler
                               recordedEvents:(nonnull NSArray<RxRecorded<RxEvent<Element> *> *> *)recordedEvents;

@end

NS_ASSUME_NONNULL_END