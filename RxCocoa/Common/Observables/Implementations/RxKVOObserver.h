//
//  RxKVOObserver
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RxObjC/RxObjC.h>
#import "_RxKVOObserver.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RxKVOObservableProtocol <NSObject>

- (nullable id)target;
- (nonnull NSString *)keyPath;
- (BOOL)retainTarget;
- (NSKeyValueObservingOptions)options;

@end

@interface RxKVOObserver : _RxKVOObserver <RxDisposable>

@property (nullable, weak, nonatomic) RxKVOObserver *retainSelf;

- (nonnull instancetype)initWithParent:(nonnull id <RxKVOObservableProtocol>)parent callback:(nonnull RxKVOCallback)callback;

@end

NS_ASSUME_NONNULL_END