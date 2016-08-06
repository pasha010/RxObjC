//
//  RxDeallocatingObservable
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxDeallocatingObservable.h"


@implementation RxDeallocatingObservable {
    RxReplaySubject *__nonnull _subject;
}

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _subject = [RxReplaySubject createWithBufferSize:1];
        _targetImplementation = Rx_default_target_implementation();
    }
    return self;
}

- (BOOL)isActive {
    return _targetImplementation != Rx_default_target_implementation();
}

- (void)messageSentWithParameters:(nonnull NSArray *)parameters {
    [_subject onNext:nil];
}

- (nonnull RxObservable *)asObservable {
    return _subject;
}

- (void)dealloc {
    [_subject onCompleted];
}

@end