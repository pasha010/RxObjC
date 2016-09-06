//
//  CLLocationManager(Rx)
//  RxObjC
// 
//  Created by Pavel Malkov on 06.09.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <RxCocoa/RxCocoa.h>
#import "CLLocationManager+Rx.h"
#import "RxCLLocationManagerDelegateProxy.h"
#import "RxDelegateProxy.h"


@implementation CLLocationManager (Rx)

- (nonnull RxDelegateProxy *)rx_delegate {
    return [RxCLLocationManagerDelegateProxy proxyForObject:self];
}

- (nonnull RxObservable<NSArray<CLLocation *> *> *)rx_didUpdateLocations {
    return [[[self rx_delegate] observe:@selector(locationManager:didUpdateLocations:)]
            map:^CLLocation *(NSArray *element) {
                return rx_castOrThrow([CLLocation class], element[1]);
            }];
}

- (nonnull RxObservable<NSError *> *)rx_didFailWithError {
    return [[[self rx_delegate] observe:@selector(locationManager:didFailWithError:)]
            map:^NSError *(NSArray *element) {
                return rx_castOrThrow([NSError class], element[1]);
            }];
}

- (nonnull RxObservable<NSError *> *)rx_didFinishDeferredUpdatesWithError {
    return [[[self rx_delegate] observe:@selector(locationManager:didFinishDeferredUpdatesWithError:)]
            map:^NSError *(NSArray *element) {
                return rx_castOrThrow([NSError class], element[1]);
            }];
}

#if TARGET_OS_IOS

- (nonnull RxObservable *)rx_didPauseLocationUpdates {
    return [[[self rx_delegate] observe:@selector(locationManagerDidPauseLocationUpdates:)]
            map:^id(id _) {
                return nil;
            }];
}

- (nonnull RxObservable *)rx_didResumeLocationUpdates {
    return [[[self rx_delegate] observe:@selector(locationManagerDidResumeLocationUpdates:)]
            map:^id(id _) {
                return nil;
            }];
}

- (nonnull RxObservable<CLHeading *> *)rx_didUpdateHeading {
    return [[[self rx_delegate] observe:@selector(locationManager:didUpdateHeading:)]
            map:^CLHeading *(NSArray *a) {
                return rx_castOrThrow([CLHeading class], a[1]);
            }];
}

- (nonnull RxObservable<CLRegion *> *)rx_didEnterRegion {
    return [[[self rx_delegate] observe:@selector(locationManager:didEnterRegion:)]
            map:^CLRegion *(NSArray *a) {
                return rx_castOrThrow([CLRegion class], a[1]);
            }];
}

- (nonnull RxObservable<CLRegion *> *)rx_didExitRegion {
    return [[[self rx_delegate] observe:@selector(locationManager:didExitRegion:)]
            map:^CLRegion *(NSArray *a) {
                return rx_castOrThrow([CLRegion class], a[1]);
            }];
}

#endif

#if TARGET_OS_IOS || TARGET_OS_MAC

- (nonnull RxObservable<RxTuple2<NSNumber *, CLRegion *> *> *)rx_didDetermineStateForRegion {
    return [[[self rx_delegate] observe:@selector(locationManager:didDetermineState:forRegion:)]
            map:^RxTuple2<NSNumber *, CLRegion *> *(NSArray *a) {
                NSNumber *stateNumber = rx_castOrThrow([NSNumber class], a[1]);
                CLRegionState state = (CLRegionState) stateNumber.integerValue;
                CLRegion *region = rx_castOrThrow([CLRegion class], a[2]);
                return [RxTuple2 create:@(state) and:region];
            }];
}

- (nonnull RxObservable<RxTuple2<CLRegion *, NSError *> *> *)rx_monitoringDidFailForRegionWithError {
    return [[[self rx_delegate] observe:@selector(locationManager:monitoringDidFailForRegion:withError:)]
            map:^RxTuple2<CLRegion *, NSError *> *(NSArray *a) {
                CLRegion *region = rx_castOrThrow([CLRegion class], a[1]);
                NSError *error = rx_castOrThrow([NSError class], a[2]);
                return [RxTuple2 create:region and:error];
            }];
}

- (nonnull RxObservable<CLRegion *> *)rx_didStartMonitoringForRegion {
    return [[[self rx_delegate] observe:@selector(locationManager:didStartMonitoringForRegion:)]
            map:^CLRegion *(NSArray *a) {
                return rx_castOrThrow([CLRegion class], a[1]);
            }];
}

#endif

#if TARGET_OS_IOS

- (nonnull RxObservable<RxTuple2<NSArray<CLBeacon *> *, CLBeaconRegion *> *> *)rx_didRangeBeaconsInRegion {
    return [[[self rx_delegate] observe:@selector(locationManager:didRangeBeacons:inRegion:)]
            map:^RxTuple2<NSArray<CLBeacon *> *, CLBeaconRegion *> *(NSArray *a) {
                NSArray<CLBeacon *> *beacons = rx_castOrThrow([NSArray class], a[1]);
                CLBeaconRegion *region = rx_castOrThrow([CLBeaconRegion class], a[2]);
                return [RxTuple2 create:beacons and:region];
            }];
}

- (nonnull RxObservable<RxTuple2<CLBeaconRegion *, NSError *> *> *)rx_rangingBeaconsDidFailForRegionWithError {
    return [[[self rx_delegate] observe:@selector(locationManager:rangingBeaconsDidFailForRegion:withError:)]
            map:^RxTuple2<NSArray<CLBeacon *> *, CLBeaconRegion *> *(NSArray *a) {
                CLBeaconRegion *region = rx_castOrThrow([CLBeaconRegion class], a[1]);
                NSError *error = rx_castOrThrow([NSError class], a[2]);
                return [RxTuple2 create:region and:error];
            }];
}

- (nonnull RxObservable<CLVisit *> *)rx_didVisit {
    return [[[self rx_delegate] observe:@selector(locationManager:didVisit:)]
            map:^CLVisit *(NSArray *a) {
                return rx_castOrThrow([CLVisit class], a[1]);
            }];
}

- (nonnull RxObservable<NSNumber *> *)rx_didChangeAuthorizationStatus {
    return [[[self rx_delegate] observe:@selector(locationManager:didChangeAuthorizationStatus:)]
            map:^NSNumber *(NSArray *a) {
                return rx_castOrThrow([NSNumber class], a[1]);
            }];
}

#endif

@end