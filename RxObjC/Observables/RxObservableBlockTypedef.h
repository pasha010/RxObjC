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
typedef RxAccumulateType __nonnull (^RxAccumulatorType)(RxAccumulateType __nonnull, RxSourceType __nonnull);

typedef id RxResultType;
typedef RxResultType __nonnull (^ResultSelectorType)(RxAccumulateType __nonnull);

/// multicast
typedef id <RxSubjectType> __nonnull (^RxSubjectSelectorType)();
typedef RxObservable *__nonnull (^RxSelectorType)(RxObservable *__nonnull);

/// AnonymousObservable
typedef id <RxDisposable> __nonnull(^RxAnonymousSubscribeHandler)(RxAnyObserver *__nonnull);

/// zip
typedef id __nonnull (^RxZip2ResultSelector)(id __nonnull o1, id __nonnull o2);
typedef id __nonnull (^RxZip3ResultSelector)(id __nonnull o1, id __nonnull o2, id __nonnull o3);
typedef id __nonnull (^RxZip4ResultSelector)(id __nonnull o1, id __nonnull o2, id __nonnull o3, id __nonnull o4);
typedef id __nonnull (^RxZip5ResultSelector)(id __nonnull o1, id __nonnull o2, id __nonnull o3, id __nonnull o4, id __nonnull o5);
typedef id __nonnull (^RxZip6ResultSelector)(id __nonnull o1, id __nonnull o2, id __nonnull o3, id __nonnull o4, id __nonnull o5, id __nonnull o6);
typedef id __nonnull (^RxZip7ResultSelector)(id __nonnull o1, id __nonnull o2, id __nonnull o3, id __nonnull o4, id __nonnull o5, id __nonnull o6, id __nonnull o7);
typedef id __nonnull (^RxZip8ResultSelector)(id __nonnull o1, id __nonnull o2, id __nonnull o3, id __nonnull o4, id __nonnull o5, id __nonnull o6, id __nonnull o7, id __nonnull o8);
typedef id __nonnull (^RxZipTupleResultSelector)(RxTuple *__nonnull);

typedef void (^RxZipObserverValueSetter)(id __nonnull);

/// map
typedef id __nonnull (^RxMapSelector)(id __nonnull);
typedef id __nonnull (^RxMapWithIndexSelector)(id __nonnull, NSInteger);

/// defer
typedef RxObservable *__nonnull (^RxObservableFactory)();

/// using
typedef id <RxDisposable> __nonnull (^RxUsingResourceFactory)();
typedef RxObservable *__nonnull (^RxUsingObservableFactory)(id <RxDisposable> __nonnull);

#endif /* RxObservableBlockTypedef_h */
