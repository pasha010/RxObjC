//
//  RxObjC
//  RxObjC
// 
//  Created by Pavel Malkov on 11.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#ifndef RxObjC_H
#define RxObjC_H

#import <Foundation/Foundation.h>
#import "RxObjCCommon.h"

//! Project version number for RxObjC.
FOUNDATION_EXPORT double RxObjCVersionNumber;

//! Project version string for RxObjC.
FOUNDATION_EXPORT const unsigned char RxObjCVersionString[];

#pragma mark - Concurrency
#import "RxAsyncLock.h"
#import "RxLock.h"
#import "RxLockOwnerType.h"
#import "RxSynchronizedDisposeType.h"
#import "RxSynchronizedOnType.h"
#import "RxSynchronizedSubscribeType.h"
#import "RxSynchronizedUnsubscribeType.h"

#pragma mark - DataStructures
#import "RxBag.h"
#import "RxInfiniteSequence.h"
#import "RxPriorityQueue.h"
#import "RxQueue.h"
#import "RxTuple.h"

#pragma mark - Disposables
#import "RxAnonymousDisposable.h"
#import "RxBinaryDisposable.h"
#import "RxBooleanDisposable.h"
#import "RxCompositeDisposable.h"
#import "RxDisposeBag.h"
#import "RxDisposeBase.h"
#import "RxNopDisposable.h"
#import "RxRefCountDisposable.h"
#import "RxScheduledDisposable.h"
#import "RxSerialDisposable.h"
#import "RxSingleAssignmentDisposable.h"
#import "RxStableCompositeDisposable.h"
#import "RxSubscriptionDisposable.h"

/*#pragma mark - Observable implementations
#import "RxAddRef.h"
#import "RxAmb.h"
#import "RxAnonymousObservable.h"
#import "RxBufferTimeCount.h"
#import "RxCatch.h"
#import "RxCombineLatest+CollectionType.h"
#import "RxCombineLatest+Private.h"
#import "RxCombineLatest.h"
#import "RxConcat.h"
#import "RxConnectableObservable.h"
#import "RxDebugProducer.h"
#import "RxDeferred.h"
#import "RxDelaySubscription.h"
#import "RxDistinctUntilChanged.h"
#import "RxDo.h"
#import "RxElementAt.h"
#import "RxEmpty.h"
#import "RxErrorProducer.h"
#import "RxFilter.h"
#import "RxGenerate.h"
#import "RxJust.h"
#import "RxMap.h"
#import "RxMerge+Private.h"
#import "RxMerge.h"
#import "RxMulticast.h"
#import "RxNever.h"
#import "RxObserveOn.h"
#import "RxObserveOnSerialDispatchQueue.h"
#import "RxProducer.h"
#import "RxRange.h"
#import "RxReduce.h"
#import "RxRefCount.h"
#import "RxRepeatElement.h"
#import "RxRetryWhen.h"
#import "RxSample.h"
#import "RxScan.h"
#import "RxSequence.h"
#import "RxShareReplay1.h"
#import "RxShareReplay1WhileConnected.h"
#import "RxSingleAsync.h"
#import "RxSink.h"
#import "RxSkip.h"
#import "RxSkipUntil.h"
#import "RxSkipWhile.h"
#import "RxStartWith.h"
#import "RxSubscribeOn.h"
#import "RxSwitch.h"
#import "RxTake.h"
#import "RxTakeLast.h"
#import "RxTakeUntil.h"
#import "RxTakeWhile.h"
#import "RxThrottle.h"
#import "RxTimeout.h"
#import "RxTimer.h"
#import "RxToArray.h"
#import "RxUsing.h"
#import "RxWindow.h"
#import "RxWithLatestFrom.h"
#import "RxZip+CollectionType.h"
#import "RxZip+Private.h"
#import "RxZip.h"*/

#pragma mark - Obserbables operations
#import "RxObservable+Aggregate.h"
#import "RxObservable+Binding.h"
#import "RxObservable+CombineLatest.h"
#import "RxObservable+Concurrency.h"
#import "RxObservable+Creation.h"
#import "RxObservable+Debug.h"
#import "RxObservable+Multiple.h"
#import "RxObservable+Single.h"
#import "RxObservable+StandardSequenceOperators.h"
#import "RxObservable+Time.h"
#import "RxObservable+Zip.h"
#import "RxObservableBlockTypedef.h"

#pragma mark - Observers
#import "RxAnonymousObserver.h"
#import "RxObserverBase.h"
#import "RxTailRecursiveSink.h"
#import "NSThread+RxLocalStorageValue.h"

#pragma mark - Common
#import "RxAnyObserver.h"
#import "RxCancelable.h"
#import "RxConnectableObservableType.h"
#import "RxDisposable.h"
#import "RxError.h"
#import "RxEvent.h"
#import "RxImmediateSchedulerType.h"
#import "RxMutableBox.h"
#import "RxObjC.h"
#import "RxObjCCommon.h"
#import "RxObjCExt.h"
#import "RxObservable+Extension.h"
#import "RxObservable.h"
#import "RxObservableConvertibleType.h"
#import "RxObservableType.h"
#import "RxObserverType.h"
#import "RxSchedulerType.h"

/*#pragma mark -- Schedulers internal
#import "RxInvocableScheduledItem.h"
#import "RxInvocableType.h"
#import "RxScheduledItem.h"
#import "RxScheduledItemType.h"*/

#pragma mark - Schedulers
#import "RxCurrentThreadScheduler.h"
#import "RxDispatchQueueSchedulerQOS.h"
#import "RxHistoricalScheduler.h"
#import "RxHistoricalSchedulerTimeConverter.h"
#import "RxMainScheduler.h"
#import "RxRecursiveScheduler.h"
#import "RxSchedulers.h"
#import "RxSchedulerServices+Emulation.h"
#import "RxSerialDispatchQueueScheduler.h"
#import "RxVirtualTimeConverterType.h"
#import "RxVirtualTimeScheduler.h"

#pragma mark - Subjects
#import "RxBehaviorSubject.h"
#import "RxPublishSubject.h"
#import "RxReplaySubject.h"
#import "RxSubjectType.h"
#import "RxVariable.h"

#endif // RxObjC_H