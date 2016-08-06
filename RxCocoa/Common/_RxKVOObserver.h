//
//  _RxKVOObserver.h
//  RxCocoa
//
//  Created by Pavel Malkov on 19.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * ################################################################################
 * This file is part of RX private API
 * ################################################################################
 */

NS_ASSUME_NONNULL_BEGIN

typedef void (^RxKVOCallback)(id __nullable object);

@interface _RxKVOObserver<E> : NSObject

- (nonnull instancetype)initWithTarget:(nonnull E)target
                          retainTarget:(BOOL)retainTarget
                               keyPath:(nonnull NSString *)keyPath
                               options:(NSKeyValueObservingOptions)options
                              callback:(nonnull RxKVOCallback)callback;

- (void)dispose;

@end

NS_ASSUME_NONNULL_END
