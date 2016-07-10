//
//  RxAny
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A way to use built in XCTest methods with objects that are partially equatable.

 If this can be done simpler, PRs are welcome :)
 */
typedef BOOL (^RxAnyComparer)(id __nonnull, id __nonnull);

@interface RxAny<Target> : NSObject

@property (nonnull, readonly) Target target;
@property (copy, readonly) RxAnyComparer comparer;

- (nonnull instancetype)initWithTarget:(nonnull Target)target comparer:(RxAnyComparer)comparer;

@end

NS_ASSUME_NONNULL_END