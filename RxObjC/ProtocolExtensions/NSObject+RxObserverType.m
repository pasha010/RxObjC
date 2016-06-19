//
// Created by Pavel Malkov on 19.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "NSObject+RxObserverType.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation NSObject (RxObserverType)

- (void)onNext:(nullable id)element {
    if ([self respondsToSelector:@selector(on:)]) {
        [self on:[RxEvent next:element]];
    }
}

- (void)onCompleted {
    if ([self respondsToSelector:@selector(on:)]) {
        [self on:[RxEvent completed]];
    }
}

- (void)onError:(nullable NSError *)error {
    if ([self respondsToSelector:@selector(on:)]) {
        [self on:[RxEvent error:error]];
    }
}

@end
#pragma clang diagnostic pop