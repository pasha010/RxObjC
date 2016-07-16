//
//  RxLazyEnumerator
//  RxObjC
// 
//  Created by Pavel Malkov on 16.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxLazyEnumerator.h"


@implementation RxLazyEnumerator {
    NSEnumerator<RxLazyEnumeratorBlock> *__nonnull _lazyEnumerator;
    NSArray<RxLazyEnumeratorBlock> *_lazyObjects;
}
- (nonnull instancetype)initWithObjects:(nonnull NSArray<RxLazyEnumeratorBlock> *)lazyObjects {
    self = [super init];
    if (self) {
        _lazyObjects = [lazyObjects copy];
        _lazyEnumerator = [lazyObjects objectEnumerator];
    }
    return self;
}

- (nullable id)nextObject {
    return [_lazyEnumerator nextObject]();
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained[])buffer count:(NSUInteger)len {
    return [_lazyEnumerator countByEnumeratingWithState:state objects:buffer count:len];
}

- (nonnull NSArray<id> *)allObjects {
    return _lazyObjects;
}

@end