//
//  RxKVOObservable
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RxObjC/RxObjC.h>
#import "RxKVOObserver.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxKVOObservable<Element> : NSObject <RxObservableType, RxKVOObservableProtocol>

@property (nullable, weak, nonatomic) id target;
@property (nonnull, strong, nonatomic) NSString *keyPath;
@property (assign, nonatomic) BOOL retainTarget;
@property (assign, nonatomic) NSKeyValueObservingOptions options;

- (nonnull instancetype)initWithObject:(nonnull id)target
                               keyPath:(nonnull NSString *)keyPath
                               options:(NSKeyValueObservingOptions)options
                          retainTarget:(BOOL)retainTarget;

@end

#if !DISABLE_SWIZZLING

FOUNDATION_EXTERN RxObservable *__nonnull rx_observeWeaklyKeyPathFor(NSObject *__nonnull target, NSString *__nonnull keyPath, NSKeyValueObservingOptions options);

/**
 * This should work correctly
 * Identifiers can't contain `,`, so the only place where `,` can appear
 * is as a delimiter.
 * This means there is `W` as element in an array of property attributes.
 */
FOUNDATION_EXTERN BOOL rx_isWeakProperty(NSString *__nonnull propertyRuntimeInfo);

@interface RxObservable<E> (FinishWhenDealloc)

- (nonnull RxObservable<E> *)finishWithNilWhenDealloc:(nonnull NSObject *)target;

@end

FOUNDATION_EXTERN RxObservable *__nonnull rx_observeWeaklyKeyPathSectionsFor(NSObject *__nonnull target, NSArray<NSString *> *__nonnull keyPathSections, NSKeyValueObservingOptions options);

#endif

NS_ASSUME_NONNULL_END