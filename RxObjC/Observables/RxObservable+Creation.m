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


@implementation RxObservable (Create)

+ (nonnull instancetype)create:(RxAnonymousSubscribeHandler)subscribe {
    return [[RxAnonymousObservable alloc] initWithSubscribeHandler:subscribe];
}

@end