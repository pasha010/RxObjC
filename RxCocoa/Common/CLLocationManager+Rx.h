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

#if TARGET_OS_IOS || TARGET_OS_MAC

- (nonnull RxObservable<NSError *> *)rx_didFinishDeferredUpdatesWithError;

#endif

#if TARGET_OS_IOS

- (nonnull RxObservable *)rx_didPauseLocationUpdates;

- (nonnull RxObservable *)rx_didResumeLocationUpdates;

- (nonnull RxObservable<CLHeading *> *)rx_didUpdateHeading;

- (nonnull RxObservable<CLRegion *> *)rx_didEnterRegion;

- (nonnull RxObservable<CLRegion *> *)rx_didExitRegion;
#endif

#if TARGET_OS_IOS || TARGET_OS_OSX

- (nonnull RxObservable<RxTuple2<NSNumber * /*CLRegionState*/, CLRegion *> *> *)rx_didDetermineStateForRegion NS_AVAILABLE(10_10, 8_0);

- (nonnull RxObservable<RxTuple2<CLRegion *, NSError *> *> *)rx_monitoringDidFailForRegionWithError;

- (nonnull RxObservable<CLRegion *> *)rx_didStartMonitoringForRegion;

#endif

#if TARGET_OS_IOS
- (nonnull RxObservable<RxTuple2<NSArray <CLBeacon *> *, CLBeaconRegion *> *> *)rx_didRangeBeaconsInRegion;

- (nonnull RxObservable<RxTuple2<CLBeaconRegion *, NSError *> *> *)rx_rangingBeaconsDidFailForRegionWithError;

- (nonnull RxObservable<CLVisit *> *)rx_didVisit;

- (nonnull RxObservable<NSNumber/*<CLAuthorizationStatus>*/ *> *)rx_didChangeAuthorizationStatus;

#endif

@end

NS_ASSUME_NONNULL_END