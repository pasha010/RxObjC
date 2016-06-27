//
//  RxObservable(Debug)
//  RxObjC
// 
//  Created by Pavel Malkov on 26.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable+Debug.h"


@implementation NSObject (RxDebug)

- (nonnull RxObservable *)debug:(NSString *)identifier {
    return [self debug:identifier file:[NSString stringWithFormat:@"%s", __FILE__]];
}

- (nonnull RxObservable *)debug:(NSString *)identifier file:(NSString *)file {
    return [self debug:identifier file:file line:__LINE__];
}

- (nonnull RxObservable *)debug:(NSString *)identifier file:(NSString *)file line:(NSUInteger)line {
    return [self debug:identifier file:file line:line function:[NSString stringWithFormat:@"%s", __FUNCTION__]];
}

- (nonnull RxObservable *)debug:(NSString *)identifier file:(NSString *)file line:(NSUInteger)line function:(NSString *)function {
    // TODO implement
    return nil;
}


@end