//
//  _RxCocoaDelegateProxy.h
//  RxCocoa
//
//  Created by Pavel Malkov on 18.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface _RxCocoaDelegateProxy : NSObject

@property (nonatomic, assign, readonly) id _forwardToDelegate;

-(void)_setForwardToDelegate:(id)forwardToDelegate retainDelegate:(BOOL)retainDelegate;

-(BOOL)hasWiredImplementationForSelector:(SEL)selector;

-(void)interceptedSelector:(SEL)selector withArguments:(NSArray*)arguments;

@end

NS_ASSUME_NONNULL_END
