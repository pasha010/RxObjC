//
//  RxDebugProducer
//  RxObjC
// 
//  Created by Pavel Malkov on 09.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxDebugProducer<Element> : RxProducer<Element> {
@package
    RxObservable<Element> *__nonnull _source;
    NSString *__nonnull _identifier;
}

- (nonnull instancetype)initWithSource:(nonnull RxObservable<Element> *)source
                            identifier:(nullable NSString *)identifier
                                  file:(nonnull NSString *)file
                                  line:(nonnull NSString *)line
                              function:(nonnull NSString *)function;


@end

NS_ASSUME_NONNULL_END