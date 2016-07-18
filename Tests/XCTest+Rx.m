//
//  XCTest(Rx)
//  RxObjC
// 
//  Created by Pavel Malkov on 22.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "XCTest+Rx.h"
#import "RxRecorded.h"
#import "RxEvent.h"

@implementation XCTest (Rx)

- (nonnull RxRecorded<RxEvent *> *)next:(nonnull id)element {
    return [self next:0 element:element];
}

- (nonnull RxRecorded<RxEvent *> *)next:(RxTestTime)time element:(nonnull id)element {
    return next(time, element);
}

RxRecorded<RxEvent *> *next(RxTestTime time, id element) {
    return [[RxRecorded alloc] initWithTime:time value:[RxEvent next:element]];
}

- (nonnull RxRecorded<RxEvent *> *)completed {
    return [self completed:0];
}

- (nonnull RxRecorded<RxEvent *> *)completed:(RxTestTime)time {
    return completed(time);
}

RxRecorded<RxEvent *> *completed(RxTestTime time) {
    return [[RxRecorded alloc] initWithTime:time value:[RxEvent completed]];
}

- (nonnull RxRecorded<RxEvent *> *)error:(nonnull NSError *)error {
    return [self error:0 testError:error];
}

- (nonnull RxRecorded<RxEvent *> *)error:(RxTestTime)time testError:(nonnull NSError *)e {
    return error(time, e);
}

RxRecorded<RxEvent *> *error(RxTestTime time, NSError *error) {
    return [[RxRecorded alloc] initWithTime:time value:[RxEvent error:error]];
}
@end