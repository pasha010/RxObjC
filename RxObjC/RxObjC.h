//
//  RxObjC
//  RxObjC
// 
//  Created by Pavel Malkov on 11.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#ifndef RxObjC_H
#define RxObjC_H

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
#endif
#import <libkern/OSAtomic.h>
#import "RxObjCCommon.h"

//! Project version number for RxObjC.
FOUNDATION_EXPORT double RxObjCVersionNumber;

//! Project version string for RxObjC.
FOUNDATION_EXPORT const unsigned char RxObjCVersionString[];

#endif // RxObjC_H