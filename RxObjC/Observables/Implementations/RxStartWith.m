//
//  RxStartWith
//  RxObjC
// 
//  Created by Pavel Malkov on 28.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxStartWith.h"


@implementation RxStartWith {
    RxObservable *__nonnull _source;
    NSArray *__nonnull _elements;

}

- (nonnull instancetype)initWithSource:(nonnull RxObservable *)source elements:(nonnull NSArray *)elements {
    self = [super init];
    if (self) {
        _source = source;
        _elements = elements;
    }

    return self;
}

- (nonnull id <RxDisposable>)run:(nonnull id <RxObserverType>)observer {
    for (id element in _elements) {
        [observer on:[RxEvent next:element]];
    }
    return [_source subscribe:observer];
}


@end