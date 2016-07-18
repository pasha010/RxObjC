//
//  RxHistoricalSchedulerTimeConverter
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxVirtualTimeConverterType.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Converts historial virtual time into real time.
 *
 * Since historical virtual time is also measured in `NSDate`, this converter is identity function.
 */
@interface RxHistoricalSchedulerTimeConverter : NSObject <RxVirtualTimeConverterType>

@end

NS_ASSUME_NONNULL_END