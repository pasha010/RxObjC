//
//  RxElementIndexPair
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RxElementIndexPair : NSObject

@property (readonly) NSUInteger element;
@property (readonly) NSUInteger index;

- (nonnull instancetype)initWithElement:(NSUInteger)element
                                  index:(NSUInteger)index;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToPair:(RxElementIndexPair *)pair;


@end

NS_ASSUME_NONNULL_END