//
//  NSNotificationCenter(RxObjC)
//  RxObjC
// 
//  Created by Pavel Malkov on 25.08.17.
//  Copyright (c) 2014-2017 Pavel Malkov. All rights reserved.
//

#import <RxObjC/RxObjC.h>
#import "NSNotificationCenter+RxObjC.h"

@implementation NSNotificationCenter (RxObjC)

- (nonnull RxObservable<NSNotification *> *)rx_notificationForName:(NSString *)name object:(id)object {
    @weakify(object);
    return [RxObservable create:^id <RxDisposable>(RxAnyObserver *observer) {
        @strongify(object);
        id <NSObject> nsObserver = [self addObserverForName:name object:object queue:nil usingBlock:^(NSNotification *notification) {
            [observer onNext:notification];
        }];
        return [RxAnonymousDisposable create:^{
            [self removeObserver:nsObserver];
        }];
    }];
}

- (nonnull RxObservable<NSNotification *> *)rx_notificationForName:(NSString *)name {
    return [self rx_notificationForName:name object:nil];
}

@end