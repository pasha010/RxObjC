//
//  RxMessageSentObservable
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxMessageSentObservable.h"


@implementation RxMessageSentObservable {
    RxPublishSubject<NSArray<id> *> *__nonnull _subject;
}

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _subject = [RxPublishSubject create];
        _targetImplementation = Rx_default_target_implementation();
    }
    return self;
}

- (BOOL)isActive {
    return _targetImplementation != Rx_default_target_implementation();
}

- (void)messageSentWithParameters:(nonnull NSArray *)parameters {
    rx_onNext(_subject, parameters);
}

- (nonnull RxObservable *)asObservable {
    return _subject;
}

- (void)dealloc {
    rx_onCompleted(_subject);
}

@end