//
//  RxObjC.h
//  RxObjC
//
//  Created by Pavel Malkov on 18.06.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
#endif
#import <libkern/OSAtomic.h>
#import <libextobjc/extobjc.h>

#define TRACE_RESOURCES 1

FOUNDATION_EXTERN int32_t rx_resourceCount;

//! Project version number for RxObjC.
FOUNDATION_EXPORT double RxObjCVersionNumber;

//! Project version string for RxObjC.
FOUNDATION_EXPORT const unsigned char RxObjCVersionString[];

FOUNDATION_EXTERN id rx_abstractMethod();
FOUNDATION_EXTERN void rx_fatalError(NSString *message);
FOUNDATION_EXTERN NSInteger rx_incrementChecked(NSInteger *i);
FOUNDATION_EXTERN NSInteger rx_decrementChecked(NSInteger *i);
FOUNDATION_EXTERN NSUInteger rx_incrementCheckedUnsigned(NSUInteger *i);
FOUNDATION_EXTERN NSUInteger rx_decrementCheckedUnsigned(NSUInteger *i);