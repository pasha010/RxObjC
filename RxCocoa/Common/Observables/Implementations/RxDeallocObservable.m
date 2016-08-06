//
//  RxDeallocObservable
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxDeallocObservable.h"


@implementation RxDeallocObservable

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _subject = [RxReplaySubject createWithBufferSize:1];
    }
    return self;
}

- (void)dealloc {
    [_subject onNext:nil];
    [_subject onCompleted];
}

@end