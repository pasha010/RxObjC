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

#pragma mark - Observables operations
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

#pragma mark - Schedulers
#import "RxSchedulers.h"
#import "RxConcurrentDispatchQueueScheduler.h"
#import "RxConcurrentMainScheduler.h"
#import "RxCurrentThreadScheduler.h"
#import "RxDispatchQueueSchedulerQOS.h"
#import "RxHistoricalScheduler.h"
#import "RxHistoricalSchedulerTimeConverter.h"
#import "RxMainScheduler.h"
#import "RxOperationQueueScheduler.h"
#import "RxRecursiveScheduler.h"
#import "RxSchedulersTypes.h"
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

#pragma mark - Extensions
#import "NSEnumerator+Operators.h"

#endif // RxObjC_H