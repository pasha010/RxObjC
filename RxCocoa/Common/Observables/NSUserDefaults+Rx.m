//
//  NSUserDefaults(Rx)
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "NSUserDefaults+Rx.h"
#import "NSNotificationCenter+Rx.h"
#import "NSObject+Rx.h"


@implementation NSUserDefaults (Rx)

- (nonnull RxObservable *)rx_observeKey:(nullable NSString *)key {
    __block BOOL ignoreNextValue = NO;

    @weakify(self);
    return [RxObservable create:^id <RxDisposable>(RxAnyObserver *observer) {
        return [[[[[[[NSNotificationCenter defaultCenter] rx_notificationForName:NSUserDefaultsDidChangeNotification object:self]
                map:^id(id element) {
                    @strongify(self);
                    return [self objectForKey:key];
                }]
                filter:^BOOL(id element) {
                    if (ignoreNextValue) {
                        ignoreNextValue = NO;
                        return NO;
                    }
                    return YES;
                }]
                distinctUntilChanged]
                takeUntil:[self rx_deallocated]]
                subscribeOnNext:^(id element) {
                    @strongify(self);

                    ignoreNextValue = YES;
                    id value = element == [RxNil null] ? nil : element;
                    [self setObject:value forKey:key];

                    [observer onNext:value];
                } onError:^(NSError *error) {
                    [observer onError:error];
                } onCompleted:^{
                    [observer onCompleted];
                }];

    }];
}

@end