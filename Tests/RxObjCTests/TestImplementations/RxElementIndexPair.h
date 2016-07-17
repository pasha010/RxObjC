//
//  RxElementIndexPair
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RxElementIndexPair<E> : NSObject

@property (readonly) E element;
@property (readonly) NSUInteger index;

- (nonnull instancetype)initWithElement:(E)element
                                  index:(NSUInteger)index;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToPair:(RxElementIndexPair *)pair;


@end

NS_ASSUME_NONNULL_END