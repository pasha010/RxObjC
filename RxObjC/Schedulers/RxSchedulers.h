//
//  RxSchedulers.h
//  RxObjC
//
//  Created by Pavel Malkov on 20.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#ifndef RxSchedulers_h
#define RxSchedulers_h

#import <Foundation/Foundation.h>

@class RxAnyRecursiveScheduler;

typedef void (^RxRecursiveImmediateAction)(id __nullable state, void(^__nonnull recurse)(id __nullable));

typedef void (^RxAnyRecursiveSchedulerAction)(id __nullable state, RxAnyRecursiveScheduler * __nonnull scheduler);


#endif /* RxSchedulers_h */
