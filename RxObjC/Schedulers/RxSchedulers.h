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

typedef void (^RxRecursiveImmediateAction)(id, void(^recurse)(id));

typedef void (^RxAnyRecursiveSchedulerAction)(id state, RxAnyRecursiveScheduler *scheduler);


#endif /* RxSchedulers_h */
