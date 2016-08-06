//
//  NSNotificationCenter(Rx)
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "NSNotificationCenter+Rx.h"


@implementation NSNotificationCenter (Rx)

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