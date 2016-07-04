//
//  RxObjC.h
//  RxObjC
//
//  Created by Pavel Malkov on 18.06.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <libkern/OSAtomic.h>
#import <libextobjc/extobjc.h>

#define TRACE_RESOURCES 1

static int32_t rx_resourceCount = 0;

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