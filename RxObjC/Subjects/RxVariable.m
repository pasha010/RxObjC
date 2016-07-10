//
//  RxVariable
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxVariable.h"
#import "RxObservable.h"
#import "RxSubjectType.h"
#import "RxBehaviorSubject.h"
#import "RxLock.h"


@implementation RxVariable {
    RxBehaviorSubject *__nonnull _subject;
    RxSpinLock *__nonnull _lock;
    id __nonnull _value;
}

+ (nonnull instancetype)create:(nonnull id)value {
    return [[self alloc] initWithValue:value];
}

- (nonnull instancetype)initWithValue:(nonnull id)value {
    self = [super init];
    if (self) {
        _lock = [[NSRecursiveLock alloc] init];
        _value = value;
        _subject = [RxBehaviorSubject create:_value];
    }
    return self;
}

- (nonnull id)value {
    return [_lock calculateLocked:^id {
        return _value;
    }];
}

- (void)setValue:(nonnull id)value {
    [_lock lock];
    _value = value;
    [_lock unlock];
    [_subject on:[RxEvent next:_value]];
}

- (nonnull RxObservable<id> *)asObservable {
    return _subject;
}

- (void)dealloc {
    [_subject on:[RxEvent completed]];
}

@end