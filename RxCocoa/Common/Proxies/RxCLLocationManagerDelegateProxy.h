//
//  RxCLLocationManagerDelegateProxy
//  RxObjC
// 
//  Created by Pavel Malkov on 06.09.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RxObjC/RxObjC.h>
#import <CoreLocation/CoreLocation.h>
#import "RxDelegateProxyType.h"
#import "RxCocoaDelegateProxy.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxCLLocationManagerDelegateProxy : RxCocoaDelegateProxy <CLLocationManagerDelegate, RxDelegateProxyType>

@end

NS_ASSUME_NONNULL_END