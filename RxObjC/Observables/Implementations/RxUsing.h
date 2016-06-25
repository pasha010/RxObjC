//
//  RxUsing
//  RxObjC
// 
//  Created by Pavel Malkov on 25.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RxUsing<SourceType, ResourceType: id <RxDisposable>> : RxProducer<SourceType> {
@package
    RxUsingResourceFactory _resourceFactory;
    RxUsingObservableFactory _observableFactory;
}

- (nonnull instancetype)initWithResourceFactory:(RxUsingResourceFactory)resourceFactory
                              observableFactory:(RxUsingObservableFactory)observableFactory;


@end

NS_ASSUME_NONNULL_END