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
@class RxTuple;

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

/// zip
typedef id (^RxZip2ResultSelector)(id o1, id o2);
typedef id (^RxZip3ResultSelector)(id o1, id o2, id o3);
typedef id (^RxZip4ResultSelector)(id o1, id o2, id o3, id o4);
typedef id (^RxZip5ResultSelector)(id o1, id o2, id o3, id o4, id o5);
typedef id (^RxZip6ResultSelector)(id o1, id o2, id o3, id o4, id o5, id o6);
typedef id (^RxZip7ResultSelector)(id o1, id o2, id o3, id o4, id o5, id o6, id o7);
typedef id (^RxZip8ResultSelector)(id o1, id o2, id o3, id o4, id o5, id o6, id o7, id o8);
typedef id (^RxZipTupleResultSelector)(RxTuple *__nonnull);

typedef void (^RxZipObserverValueSetter)(id);

/// map
typedef id (^RxMapSelector)(id);
typedef id (^RxMapWithIndexSelector)(id, NSInteger);

#endif /* RxObservableBlockTypedef_h */
