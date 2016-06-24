//
//  RxEmpty
//  RxObjC
// 
//  Created by Pavel Malkov on 24.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxEmpty.h"
#import "RxCurrentThreadScheduler.h"
#import "RxNopDisposable.h"

@implementation RxEmpty

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    [observer on:[RxEvent completed]];
    return [RxNopDisposable sharedInstance];
}

@end