//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObserverType.h"

void rx_onNext(id <RxObserverType> _Nonnull observer, id _Nullable element) {
    [observer on:[RxEvent next:element]];
}

void rx_onCompleted(id <RxObserverType> _Nonnull observer) {
    [observer on:[RxEvent completed]];
}

void rx_onError(id <RxObserverType> _Nonnull observer, NSError *_Nullable error) {
    [observer on:[RxEvent error:error]];
}