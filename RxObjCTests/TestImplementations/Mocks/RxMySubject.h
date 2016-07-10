//
//  RxMySubject
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxSubjectType.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxMySubject<Element> : NSObject <RxSubjectType, RxObserverType>

@property (readonly) NSUInteger subscribeCount;
@property (readonly) BOOL disposed;

+ (nonnull instancetype)create;
- (nonnull instancetype)init;

- (void)disposeOn:(nonnull Element)value disposable:(nonnull id <RxDisposable>)disposable;

- (nonnull instancetype)asObserver;

@end

NS_ASSUME_NONNULL_END