//
//  RxObservable(Creation)
//  RxObjC
// 
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable+Creation.h"
#import "RxAnyObserver.h"
#import "RxAnonymousObservable.h"
#import "RxErrorProducer.h"
#import "RxImmediateSchedulerType.h"
#import "RxSequence.h"
#import "RxEmpty.h"
#import "RxJust.h"


@implementation RxObservable (Create)

+ (nonnull RxObservable *)create:(RxAnonymousSubscribeHandler)subscribe {
    return [[RxAnonymousObservable alloc] initWithSubscribeHandler:subscribe];
}

@end

@implementation RxObservable (Empty)

+ (nonnull RxObservable *)empty {
    return [[RxEmpty alloc] init];
}

@end

@implementation RxObservable (Never)

+ (nonnull RxObservable *)never {
    // TODO implement never
    return nil;
}

@end

@implementation RxObservable (Just)

+ (nonnull RxObservable *)just:(nonnull id)element {
    return [[RxJust alloc] initWithElement:element];
}

+ (nonnull RxObservable *)just:(nonnull id)element scheduler:(nonnull id <RxImmediateSchedulerType>)scheduler {
    // TODO implement JustScheduled
    return nil;
}

@end

@implementation RxObservable (Fail)

+ (nonnull RxObservable *)error:(nonnull NSError *)error {
    return [RxErrorProducer error:error];
}

@end

@implementation RxObservable (Of)

+ (nonnull RxObservable *)of:(nonnull NSArray *)elements {
    return [self of:elements scheduler:nil];
}

+ (nonnull RxObservable *)of:(nonnull NSArray *)elements scheduler:(nullable id <RxImmediateSchedulerType>)scheduler {
    return [[RxSequence alloc] initWithElements:elements scheduler:scheduler];
}

@end