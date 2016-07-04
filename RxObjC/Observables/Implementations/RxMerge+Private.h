//
//  RxMerge(Private)
//  RxObjC
// 
//  Created by Pavel Malkov on 27.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxMerge.h"
#import "RxSink.h"

@class RxCompositeDisposable;
@class RxSingleAssignmentDisposable;
@class RxBagKey;

NS_ASSUME_NONNULL_BEGIN

static NSInteger const RxMergeNoIterators = 1;

@interface RxMergeSink<SourceType, S : id <RxObservableConvertibleType>, O : id<RxObserverType>> : RxSink<O> <RxObserverType>

@property (assign, readonly) BOOL subscribeNext;
@property (nonnull, nonatomic, strong, readonly) RxCompositeDisposable *group;
@property (nonnull, nonatomic, strong, readonly) RxSingleAssignmentDisposable *sourceSubscription;
@property (nonatomic, readonly) BOOL stopped;

- (nonnull id <RxObservableConvertibleType>)performMap:(nonnull id)element;

- (nonnull id <RxDisposable>)run:(nonnull RxObservable *)source;

@end

@interface RxMergeSinkIter <SourceType, S: id <RxObservableConvertibleType>, O: id <RxObserverType>> : NSObject <RxObserverType>

@property (nonnull, readonly) RxMergeSink<SourceType, S, O> *parent;
@property (nonnull, readonly) RxBagKey *disposeKey;

@end

NS_ASSUME_NONNULL_END