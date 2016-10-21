//
//  RxCLLocationManagerDelegateProxy
//  RxObjC
// 
//  Created by Pavel Malkov on 06.09.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxCLLocationManagerDelegateProxy.h"

@implementation RxCLLocationManagerDelegateProxy

+ (nullable id)currentDelegateFor:(nonnull id)object {
    CLLocationManager *manager = rx_castOrFatalError([CLLocationManager class], object, @"");
    return manager.delegate;
}

+ (void)setCurrentDelegate:(nullable id)delegate toObject:(nonnull id)object {
    CLLocationManager *manager = rx_castOrFatalError([CLLocationManager class], object, @"");
    if (![delegate conformsToProtocol:@protocol(CLLocationManagerDelegate)]) {
        rx_fatalError(@"delegate not CLLocationManagerDelegate");
    }
    manager.delegate = delegate;
}

@end