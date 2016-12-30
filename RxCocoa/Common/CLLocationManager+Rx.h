//
//  CLLocationManager(Rx)
//  RxObjC
// 
//  Created by Pavel Malkov on 06.09.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <RxObjC/RxObjC.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@class RxCocoaDelegateProxy;

NS_ASSUME_NONNULL_BEGIN

@interface CLLocationManager (Rx)

/**
 * Reactive wrapper for `delegate`.
 * For more information take a look at `DelegateProxyType` protocol documentation.
 */
- (nonnull RxCocoaDelegateProxy *)rx_delegate;

/**
 * Reactive wrapper for `delegate` message.
 */
- (nonnull RxObservable<NSArray <CLLocation *> *> *)rx_didUpdateLocations;

/**
 * Reactive wrapper for `delegate` message.
 */
- (nonnull RxObservable<NSError *> *)rx_didFailWithError;

- (nonnull RxObservable<NSError *> *)rx_didFinishDeferredUpdatesWithError;

- (nonnull RxObservable *)rx_didPauseLocationUpdates __TVOS_PROHIBITED __WATCHOS_PROHIBITED;

- (nonnull RxObservable *)rx_didResumeLocationUpdates __TVOS_PROHIBITED __WATCHOS_PROHIBITED;

- (nonnull RxObservable<CLHeading *> *)rx_didUpdateHeading __TVOS_PROHIBITED __WATCHOS_PROHIBITED;

- (nonnull RxObservable<CLRegion *> *)rx_didEnterRegion __TVOS_PROHIBITED __WATCHOS_PROHIBITED;

- (nonnull RxObservable<CLRegion *> *)rx_didExitRegion __TVOS_PROHIBITED __WATCHOS_PROHIBITED;

- (nonnull RxObservable<RxTuple2<NSNumber * /*CLRegionState*/, CLRegion *> *> *)rx_didDetermineStateForRegion __OSX_AVAILABLE_STARTING(__MAC_10_10,__IPHONE_7_0) __TVOS_PROHIBITED __WATCHOS_PROHIBITED;

- (nonnull RxObservable<RxTuple2<CLRegion *, NSError *> *> *)rx_monitoringDidFailForRegionWithError __TVOS_PROHIBITED __WATCHOS_PROHIBITED;

- (nonnull RxObservable<CLRegion *> *)rx_didStartMonitoringForRegion __TVOS_PROHIBITED __WATCHOS_PROHIBITED;

- (nonnull RxObservable<RxTuple2<NSArray <CLBeacon *> *, CLBeaconRegion *> *> *)rx_didRangeBeaconsInRegion __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0) __TVOS_PROHIBITED __WATCHOS_PROHIBITED;

- (nonnull RxObservable<RxTuple2<CLBeaconRegion *, NSError *> *> *)rx_rangingBeaconsDidFailForRegionWithError __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0) __TVOS_PROHIBITED __WATCHOS_PROHIBITED;

- (nonnull RxObservable<CLVisit *> *)rx_didVisit __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_8_0) __TVOS_PROHIBITED __WATCHOS_PROHIBITED;

- (nonnull RxObservable<NSNumber/*<CLAuthorizationStatus>*/ *> *)rx_didChangeAuthorizationStatus __TVOS_PROHIBITED __WATCHOS_PROHIBITED;

@end

NS_ASSUME_NONNULL_END
#pragma clang diagnostic pop
