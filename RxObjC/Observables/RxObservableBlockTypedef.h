//
//  RxObservableBlockTypedef.h
//  RxObjC
//
//  Created by Pavel Malkov on 20.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#ifndef RxObservableBlockTypedef_h
#define RxObservableBlockTypedef_h

#import <Foundation/Foundation.h>

@protocol RxSubjectType;
@protocol RxDisposable;
@class RxAnyObserver;
@class RxObservable;

/// reduce
typedef id RxAccumulateType;
typedef id RxSourceType;
typedef RxAccumulateType (^RxAccumulatorType)(RxAccumulateType , RxSourceType);

typedef id RxResultType;
typedef RxResultType(^ResultSelectorType)(RxAccumulateType);

/// multicast
typedef id <RxSubjectType>(^RxSubjectSelectorType)();
typedef RxObservable *(^RxSelectorType)(RxObservable *);

/// AnonymousObservable
typedef id <RxDisposable>(^RxAnonymousSubscribeHandler)(RxAnyObserver *);

#endif /* RxObservableBlockTypedef_h */
