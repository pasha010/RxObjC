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
@protocol RxObservableConvertibleType;
@class RxAnyObserver;
@class RxObservable;
@class RxTuple;
@class RxEvent;

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
typedef id __nonnull (^RxMapSelector)(id __nonnull element);
typedef id __nonnull (^RxMapWithIndexSelector)(id __nonnull element, NSInteger index);

/// defer
typedef RxObservable *__nonnull (^RxObservableFactory)();

/// using
typedef id <RxDisposable> __nonnull (^RxUsingResourceFactory)();
typedef RxObservable *__nonnull (^RxUsingObservableFactory)(id <RxDisposable> __nonnull);

/// catch
typedef RxObservable *__nonnull (^RxCatchHandler)(NSError *__nonnull error);

/// withLatestFrom
typedef id __nonnull (^RxWithLatestFromResultSelector)(id __nonnull first, id __nonnull second);

/// distinctUntilChanged
typedef id __nonnull (^RxDistinctUntilChangedKeySelector)(id __nonnull element);
typedef BOOL (^RxDistinctUntilChangedEqualityComparer)(id __nonnull lhs, id __nonnull rhs);

/// doOn
typedef void (^RxDoOnEventHandler)(RxEvent *__nonnull event);

/// scan
typedef id __nonnull(^RxScanAccumulator)(id __nonnull accumulate, id __nonnull element);

/// filter
typedef BOOL (^RxFilterPredicate)(id __nonnull element);

/// take while
typedef BOOL (^RxTakeWhilePredicate)(id __nonnull element);
typedef BOOL (^RxTakeWhileWithIndexPredicate)(id __nonnull element, NSUInteger index);

/// skip while
typedef BOOL (^RxSkipWhilePredicate)(id __nonnull element);
typedef BOOL (^RxSkipWhileWithIndexPredicate)(id __nonnull element, NSUInteger index);

/// flat map
typedef id <RxObservableConvertibleType> __nonnull (^RxFlatMapSelector)(id __nonnull element);
typedef id <RxObservableConvertibleType> __nonnull (^RxFlatMapWithIndexSelector)(id __nonnull element, NSUInteger index);

/// combine latest collection type
typedef id __nonnull (^RxCombineLatestResultSelector)(NSArray *__nonnull elements);

/// zip collection type
typedef id __nonnull (^RxZipCollectionTypeResultSelector)(NSArray *__nonnull elements);

/// single async
typedef BOOL (^RxSingleAsyncPredicate)(id __nonnull element);

/// combine latest
typedef id __nonnull (^RxCombineLatest2ResultSelector)(id __nullable o1, id __nullable o2);
typedef id __nonnull (^RxCombineLatest3ResultSelector)(id __nullable o1, id __nullable o2, id __nullable o3);
typedef id __nonnull (^RxCombineLatest4ResultSelector)(id __nullable o1, id __nullable o2, id __nullable o3, id __nullable o4);
typedef id __nonnull (^RxCombineLatest5ResultSelector)(id __nullable o1, id __nullable o2, id __nullable o3, id __nullable o4, id __nullable o5);
typedef id __nonnull (^RxCombineLatest6ResultSelector)(id __nullable o1, id __nullable o2, id __nullable o3, id __nullable o4, id __nullable o5, id __nullable o6);
typedef id __nonnull (^RxCombineLatest7ResultSelector)(id __nullable o1, id __nullable o2, id __nullable o3, id __nullable o4, id __nullable o5, id __nullable o6, id __nullable o7);
typedef id __nonnull (^RxCombineLatest8ResultSelector)(id __nullable o1, id __nullable o2, id __nullable o3, id __nullable o4, id __nullable o5, id __nullable o6, id __nullable o7, id __nullable o8);
typedef id __nonnull (^RxCombineLatestTupleResultSelector)(RxTuple *__nonnull);

#endif /* RxObservableBlockTypedef_h */
