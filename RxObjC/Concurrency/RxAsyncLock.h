//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxDisposable.h"
#import "RxLock.h"
#import "RxSynchronizedDisposeType.h"

@protocol RxInvocableType;

NS_ASSUME_NONNULL_BEGIN

typedef void (^RxAsyncLockAction)();

/**
In case nobody holds this lock, the work will be queued and executed immediately
on thread that is requesting lock.

In case there is somebody currently holding that lock, action will be enqueued.
When owned of the lock finishes with it's processing, it will also execute
and pending work.

That means that enqueued work could possibly be executed later on a different thread.
*/
@interface RxAsyncLock<I : id <RxInvocableType>> : NSObject <RxDisposable, RxLock, RxSynchronizedDisposeType>

- (nonnull instancetype)init;

- (void)invoke:(nonnull I)action;

@end

NS_ASSUME_NONNULL_END