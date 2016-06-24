//
//  RxJust
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxJust.h"
#import "RxNopDisposable.h"


@implementation RxJust {
    id __nonnull _element;
}

- (nonnull instancetype)initWithElement:(nonnull id)element {
    self = [super init];
    if (self) {
        _element = element;
    }
    return self;
}

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    [observer on:[RxEvent next:_element]];
    [observer on:[RxEvent completed]];
    return [RxNopDisposable sharedInstance];
}


@end