//
//  RxErrorProducer
//  RxObjC
// 
//  Created by Pavel Malkov on 23.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxErrorProducer.h"
#import "RxNopDisposable.h"


@implementation RxErrorProducer {
    NSError *__nonnull _error;
}

+ (nonnull instancetype)error:(nonnull NSError *)error {
    return [[self alloc] initWithError:error];
}

- (nonnull instancetype)initWithError:(nonnull NSError *)error {
    self = [super init];
    if (self) {
        _error = error;
    }
    return self;
}

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    [observer on:[RxEvent error:_error]];
    return [RxNopDisposable sharedInstance];
}


@end